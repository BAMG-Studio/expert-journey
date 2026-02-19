
# Model Registry & Cryptographic Signing with cosign + in-toto

## Why Model Signing Matters
Without signing, an attacker who gains S3 write access can:
1. Replace your production model with a poisoned version
2. The poisoned model serves malicious predictions
3. You have no way to detect the swap

With cosign + in-toto:
- Every model artifact is cryptographically signed
- Signature is verified before deployment
- Full provenance chain from training data to deployment

## Tool Overview
| Tool | Purpose | Analogy |
|------|---------|--------|
| cosign | Sign/verify OCI artifacts | Wax seal on letter |
| in-toto | Software supply chain attestation | Notarized chain of custody |
| Sigstore | Public transparency log | Public blockchain for signatures |
| ECR | AWS container/model registry | Secure vault with access log |

## cosign Implementation

### Install cosign
```bash
# Install cosign
curl -O -L https://github.com/sigstore/cosign/releases/download/v2.2.0/cosign-linux-amd64
chmod +x cosign-linux-amd64
sudo mv cosign-linux-amd64 /usr/local/bin/cosign

# Generate key pair (store private key in AWS Secrets Manager)
cosign generate-key-pair --kms awskms:///arn:aws:kms:us-east-1:123456789:key/signing-key
```

### Sign Model Artifact
```bash
# Upload model to ECR as OCI artifact
OCIFLUX_VERSION=v0.0.2
curl -Lo oras https://github.com/oras-project/oras/releases/download/${OCIFLUX_VERSION}/oras_linux_amd64
oras push 123456789.dkr.ecr.us-east-1.amazonaws.com/ml-models:interos-risk-v2.0 \
  model.tar.gz:application/vnd.ml.model

# Sign with cosign using KMS key
cosign sign \
  --key awskms:///arn:aws:kms:us-east-1:123456789:key/signing-key \
  --annotations model-name=interos-risk-model \
  --annotations model-version=2.0 \
  --annotations training-data-hash=sha256:abc123... \
  --annotations trained-by=sagemaker-job-xyz \
  123456789.dkr.ecr.us-east-1.amazonaws.com/ml-models:interos-risk-v2.0
```

### Verify Model Before Deployment
```bash
# Verify signature - MUST pass before deployment
cosign verify \
  --key awskms:///arn:aws:kms:us-east-1:123456789:key/signing-key \
  123456789.dkr.ecr.us-east-1.amazonaws.com/ml-models:interos-risk-v2.0

# Output shows:
# Verification for 123456789.dkr.ecr.us-east-1.amazonaws.com/ml-models:interos-risk-v2.0 --
# The following checks were performed on each of these signatures:
# - The cosign claims were validated
# - Existence of the claims in the transparency log was verified
# - The signatures were verified against the specified public key
```

## in-toto Supply Chain Framework

### What in-toto Tracks
in-toto creates a "chain of custody" for your ML pipeline:
```
Step 1: data-collection    -> hash of raw data
Step 2: data-preprocessing -> hash of cleaned data
Step 3: model-training     -> hash of trained model
Step 4: model-evaluation   -> test metrics + hash
Step 5: model-packaging    -> hash of model artifact
Step 6: model-signing      -> cosign signature
Step 7: deployment         -> deployment record
```

### Create in-toto Layout
```python
import json
from datetime import datetime, timedelta

layout = {
    "_type": "layout",
    "expires": (datetime.now() + timedelta(days=365)).isoformat() + "Z",
    "readme": "Interos ML Model Supply Chain Policy",
    "keys": {
        "data-team-key": {"keyid": "abc123", "keytype": "ecdsa"},
        "ml-team-key": {"keyid": "def456", "keytype": "ecdsa"},
        "security-team-key": {"keyid": "ghi789", "keytype": "ecdsa"}
    },
    "steps": [
        {
            "name": "data-preparation",
            "expected_command": ["python", "prepare_data.py"],
            "pubkeys": ["abc123"],
            "expected_materials": [],
            "expected_products": [
                ["CREATE", "training-data.parquet"],
                ["CREATE", "training-data.parquet.sha256"]
            ]
        },
        {
            "name": "model-training",
            "expected_command": ["python", "train.py"],
            "pubkeys": ["ml-team-key"],
            "expected_materials": [
                ["MATCH", "training-data.parquet", "WITH", "PRODUCTS", "FROM", "data-preparation"]
            ],
            "expected_products": [
                ["CREATE", "model.tar.gz"],
                ["CREATE", "model_metrics.json"]
            ]
        },
        {
            "name": "security-review",
            "expected_command": ["python", "security_scan.py"],
            "pubkeys": ["security-team-key"],
            "threshold": 1
        }
    ],
    "inspect": [
        {
            "name": "verify-accuracy",
            "expected_command": ["python", "-c", "import json; m=json.load(open('model_metrics.json')); assert m['accuracy'] > 0.95"],
            "expected_materials": [
                ["MATCH", "model_metrics.json", "WITH", "PRODUCTS", "FROM", "model-training"]
            ]
        }
    ]
}

with open('root.layout', 'w') as f:
    json.dump(layout, f, indent=2)
```

### Lambda Deployment Gate
```python
import boto3
import subprocess
import json

def lambda_handler(event, context):
    model_uri = event['model_uri']
    
    # Step 1: Verify cosign signature
    result = subprocess.run([
        'cosign', 'verify',
        '--key', 'awskms:///arn:aws:kms:us-east-1:123456789:key/signing-key',
        model_uri
    ], capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f'SECURITY VIOLATION: Model signature invalid for {model_uri}')
        # Alert security team
        sns = boto3.client('sns')
        sns.publish(
            TopicArn='arn:aws:sns:us-east-1:123456789:security-alerts',
            Message=f'Unsigned model deployment attempt blocked: {model_uri}',
            Subject='SECURITY ALERT: Invalid Model Signature'
        )
        return {'statusCode': 403, 'body': 'Model signature verification failed'}
    
    # Step 2: Verify in-toto attestations
    attestations = get_model_attestations(model_uri)
    if not verify_supply_chain(attestations):
        return {'statusCode': 403, 'body': 'Supply chain verification failed'}
    
    # Step 3: Deploy model
    deploy_model(model_uri)
    return {'statusCode': 200, 'body': 'Model deployed successfully'}

def get_model_attestations(model_uri):
    ecr = boto3.client('ecr')
    # Get attestations stored as OCI artifacts
    response = ecr.batch_get_image(
        repositoryName='ml-models',
        imageIds=[{'imageTag': 'attestations'}]
    )
    return json.loads(response['images'][0]['imageManifest'])
```

## SageMaker Model Registry Integration
```python
import boto3
import json

sagemaker = boto3.client('sagemaker')

# Register model with approval workflow
def register_model_package(model_s3_uri, model_metrics, cosign_signature):
    response = sagemaker.create_model_package(
        ModelPackageName='interos-risk-model-v2',
        ModelPackageDescription='Supply chain risk scoring model',
        InferenceSpecification={
            'Containers': [{
                'Image': '763104351884.dkr.ecr.us-east-1.amazonaws.com/pytorch-inference:1.12',
                'ModelDataUrl': model_s3_uri
            }],
            'SupportedContentTypes': ['application/json'],
            'SupportedResponseMIMETypes': ['application/json']
        },
        ModelApprovalStatus='PendingManualApproval',
        MetadataProperties={
            'CommitId': 'abc123def456',
            'Repository': 'interos/ml-models',
            'GeneratedBy': 'sagemaker-training-job',
            'ProjectId': 'supply-chain-risk'
        },
        ModelMetrics={
            'ModelQuality': {
                'Statistics': {
                    'ContentType': 'application/json',
                    'S3Uri': model_metrics
                }
            }
        },
        CustomerMetadataProperties={
            'cosign-signature': cosign_signature,
            'in-toto-attestation': 'verified',
            'security-review-status': 'passed'
        }
    )
    print(f'Model registered: {response["ModelPackageArn"]}')
    return response['ModelPackageArn']

# Only deploy APPROVED models
def get_approved_models():
    response = sagemaker.list_model_packages(
        ModelPackageGroupName='interos-risk-models',
        ModelApprovalStatus='Approved',
        SortBy='CreationTime',
        SortOrder='Descending'
    )
    return response['ModelPackageSummaryList']
```

## Interview Talking Points
1. cosign uses Sigstore's transparency log (Rekor) - even if you lose your signing key,
   the signatures are auditable in a public, tamper-evident log
2. in-toto ensures every step in the ML pipeline was performed by authorized parties
3. The combination prevents: model swapping, unauthorized training, data tampering
4. KMS key rotation doesn't break existing signatures - old signatures still verify

## Pidgin Explanation
Cosign be like say government dey put official stamp on document:
- Only the right person wey get the stamp fit sign am
- Anyone fit verify the stamp authentic
- If somebody try change document after stamp, verification go fail
in-toto be like say every person wey touch document must sign their part
