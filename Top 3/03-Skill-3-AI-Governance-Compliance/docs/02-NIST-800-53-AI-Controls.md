# NIST 800-53 Rev 5 Controls Mapped to AI Systems

## Key Controls for AI/ML Security

### AU-2: Audit Events
What: Define which events must be logged for AI systems

AI-Specific Audit Events:
- Training job start/stop/fail
- Model registry updates (create, approve, reject, deploy)
- Training data access (read, write, delete attempts)
- Inference API calls (who, what input, what output)
- Model configuration changes
- Feature store modifications
- SageMaker notebook access
- S3 Object Lock override attempts

AWS Implementation:
```python
import boto3

cloudtrail = boto3.client('cloudtrail')

# Create trail for ML-specific events
cloudtrail.create_trail(
    Name='interos-ml-audit-trail',
    S3BucketName='interos-audit-logs',
    IsMultiRegionTrail=True,
    EnableLogFileValidation=True,
    KmsKeyId='arn:aws:kms:us-east-1:123456789:key/audit-key',
    IncludeGlobalServiceEvents=True
)

# EventBridge rule for real-time ML event alerts
events = boto3.client('events')
events.put_rule(
    Name='ml-security-events',
    EventPattern=json.dumps({
        'source': ['aws.sagemaker'],
        'detail-type': [
            'SageMaker Training Job State Change',
            'SageMaker Model Package State Change',
            'SageMaker Endpoint Deployment'
        ]
    }),
    State='ENABLED'
)
```

### SC-28: Protection of Information at Rest
What: Encrypt all data at rest, including training data and model artifacts

AI Application:
- Training data in S3: KMS-SSE (aws:kms) encryption
- Model artifacts in S3: KMS encryption with separate key
- SageMaker notebook EBS volumes: KMS encryption
- EKS etcd: envelope encryption with KMS
- Model parameters in transit: TLS 1.2+

```bash
# Verify all S3 buckets have encryption
aws s3api get-bucket-encryption --bucket interos-ml-training-data
aws s3api get-bucket-encryption --bucket interos-ml-models

# AWS Config rule to enforce encryption
aws configservice put-config-rule --config-rule '{
  "ConfigRuleName": "s3-bucket-server-side-encryption-enabled",
  "Source": {
    "Owner": "AWS",
    "SourceIdentifier": "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  },
  "Scope": {
    "ComplianceResourceTypes": ["AWS::S3::Bucket"]
  }
}'
```

### AC-3: Access Enforcement
What: Enforce approved authorizations for all AI system resources

AI-Specific Access Controls:
```json
{
  "Principle of Least Privilege for ML Roles": {
    "Data Scientist": {
      "Can": ["Read training data", "Submit training jobs", "View metrics"],
      "Cannot": ["Deploy models", "Access production data", "Modify buckets"]
    },
    "ML Engineer": {
      "Can": ["Deploy approved models", "Monitor endpoints", "View logs"],
      "Cannot": ["Access training data directly", "Approve own models"]
    },
    "Security Engineer": {
      "Can": ["Review audit logs", "Approve model deployments", "Run scans"],
      "Cannot": ["Modify training data", "Submit training jobs"]
    },
    "AI Risk Manager": {
      "Can": ["View all metrics", "Approve governance decisions"],
      "Cannot": ["Deploy anything", "Access raw data"]
    }
  }
}
```

### RA-5: Vulnerability Scanning
What: Scan AI system components for vulnerabilities

AI Vulnerability Scanning:
1. Container Images: ECR Enhanced Scanning (Inspector)
2. Python Dependencies: pip-audit, safety, Snyk
3. ML Frameworks: Monitor CVEs for PyTorch, TensorFlow, scikit-learn
4. Model Vulnerabilities: Adversarial robustness testing
5. Data Vulnerabilities: PII detection with Macie

```bash
# Automated vulnerability scanning pipeline
# Step 1: Scan container image
aws ecr start-image-scan --repository-name ml-models --image-id imageTag=latest

# Step 2: Scan Python dependencies
pip-audit --requirement requirements.txt --format json > vuln-report.json

# Step 3: Generate SBOM
syft dir:. -o cyclonedx-json > sbom.json

# Step 4: Check SBOM against vulnerability databases
grype sbom:./sbom.json --output json > grype-report.json
```

## Complete NIST 800-53 to AI Systems Mapping
| Control | AI Application | AWS Service |
|---------|---------------|-------------|
| AU-2 | ML event logging | CloudTrail + EventBridge |
| AU-3 | Inference request details | SageMaker Data Capture |
| AU-6 | Log analysis for ML anomalies | CloudWatch Logs Insights |
| AC-2 | ML user account management | IAM + SSO |
| AC-3 | Role-based ML access | IAM policies + IRSA |
| AC-6 | Least privilege for training jobs | SageMaker execution roles |
| SC-7 | Network isolation for ML | VPC + Security Groups |
| SC-8 | Encrypt ML data in transit | TLS 1.2+ everywhere |
| SC-28 | Encrypt ML data at rest | KMS + S3 SSE |
| SI-4 | ML system monitoring | SageMaker Model Monitor |
| RA-3 | AI risk assessment | NIST AI RMF |
| RA-5 | ML dependency scanning | ECR scanning + pip-audit |
| SA-11 | ML code testing | Unit tests + adversarial tests |
| CM-2 | Model version baseline | SageMaker Model Registry |
| CM-8 | ML component inventory | SBOM with CycloneDX |
| IR-4 | AI incident handling | AI-specific IR playbook |

## Pidgin Summary
NIST 800-53 be like building code for house - every control be one rule:
- AU-2 say: write down everything wey happen (audit)
- SC-28 say: lock all your doors (encryption)
- AC-3 say: give everyone only their own key (access control)
- RA-5 say: check for holes in your wall regularly (scanning)
