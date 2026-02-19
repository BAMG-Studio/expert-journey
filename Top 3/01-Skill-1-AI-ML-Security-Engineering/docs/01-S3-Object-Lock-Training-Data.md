
# S3 Object Lock: Protecting AI Training Data

## The Problem We Are Solving
AI models learn from training data. If an attacker corrupts the training data,
the model learns wrong behavior (model poisoning). We need IMMUTABLE storage.

## S3 Object Lock - How It Works

### Retention Modes
| Mode | Can Owner Delete? | Can Admin Delete? | Use Case |
|------|------------------|-------------------|---------|
| COMPLIANCE | NO | NO | Regulatory data, audit trails |
| GOVERNANCE | NO | YES (with permission) | Training datasets, model artifacts |

### Legal Hold
- Prevents deletion regardless of retention period
- Used during security investigations
- Requires s3:PutObjectLegalHold permission

## Implementation

### Step 1: Create Bucket with Object Lock
```bash
aws s3api create-bucket \
  --bucket interos-ml-training-data \
  --region us-east-1 \
  --object-lock-enabled-for-bucket
```

### Step 2: Set Default Retention Policy
```bash
aws s3api put-object-lock-configuration \
  --bucket interos-ml-training-data \
  --object-lock-configuration '{
    "ObjectLockEnabled": "Enabled",
    "Rule": {
      "DefaultRetention": {
        "Mode": "GOVERNANCE",
        "Days": 365
      }
    }
  }'
```

### Step 3: Enable Versioning (Required for Object Lock)
```bash
aws s3api put-bucket-versioning \
  --bucket interos-ml-training-data \
  --versioning-configuration Status=Enabled
```

### Step 4: Encrypt with KMS
```bash
aws s3api put-bucket-encryption \
  --bucket interos-ml-training-data \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "arn:aws:kms:us-east-1:123456789:key/abc123"
      },
      "BucketKeyEnabled": true
    }]
  }'
```

### Step 5: Block Public Access
```bash
aws s3api put-public-access-block \
  --bucket interos-ml-training-data \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,\
    BlockPublicPolicy=true,RestrictPublicBuckets=true
```

## Python SDK Implementation
```python
import boto3
import hashlib
import json
from datetime import datetime, timezone

class ImmutableTrainingDataStore:
    def __init__(self, bucket_name, kms_key_id):
        self.s3 = boto3.client('s3')
        self.bucket = bucket_name
        self.kms_key_id = kms_key_id
    
    def upload_training_dataset(self, local_path, s3_key, dataset_name):
        # Calculate integrity hash before upload
        sha256_hash = self._calculate_sha256(local_path)
        
        # Upload with metadata
        with open(local_path, 'rb') as f:
            self.s3.put_object(
                Bucket=self.bucket,
                Key=s3_key,
                Body=f,
                ServerSideEncryption='aws:kms',
                SSEKMSKeyId=self.kms_key_id,
                Metadata={
                    'dataset-name': dataset_name,
                    'sha256-hash': sha256_hash,
                    'upload-timestamp': datetime.now(timezone.utc).isoformat(),
                    'upload-user': self._get_caller_identity()
                }
            )
        
        print(f'Uploaded {dataset_name} with hash {sha256_hash[:16]}...')
        return sha256_hash
    
    def verify_data_integrity(self, s3_key):
        # Download and verify hash matches stored metadata
        response = self.s3.get_object(Bucket=self.bucket, Key=s3_key)
        stored_hash = response['Metadata'].get('sha256-hash')
        actual_data = response['Body'].read()
        actual_hash = hashlib.sha256(actual_data).hexdigest()
        
        if stored_hash != actual_hash:
            raise SecurityError(f'DATA INTEGRITY VIOLATION: {s3_key}')
        return True
    
    def _calculate_sha256(self, file_path):
        sha256 = hashlib.sha256()
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                sha256.update(chunk)
        return sha256.hexdigest()
    
    def _get_caller_identity(self):
        sts = boto3.client('sts')
        return sts.get_caller_identity()['Arn']
```

## IAM Policy for Training Data Access
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowReadTrainingData",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::interos-ml-training-data",
        "arn:aws:s3:::interos-ml-training-data/*"
      ]
    },
    {
      "Sid": "DenyDeleteEver",
      "Effect": "Deny",
      "Action": [
        "s3:DeleteObject",
        "s3:DeleteObjectVersion",
        "s3:PutObjectRetention"
      ],
      "Resource": "arn:aws:s3:::interos-ml-training-data/*"
    }
  ]
}
```

## Security Controls Matrix (NIST 800-53)
| Control | Implementation | Verification |
|---------|---------------|-------------|
| AU-2 (Audit Events) | S3 access logs to CloudTrail | CloudWatch Logs Insights |
| SC-28 (Data at Rest) | KMS encryption on all objects | AWS Config rule |
| AC-3 (Access Enforcement) | IAM deny delete policy | IAM Access Analyzer |
| RA-5 (Vulnerability Scanning) | Macie PII detection on bucket | Security Hub findings |

## Interview Questions & Answers

Q: Why use GOVERNANCE mode instead of COMPLIANCE mode?
A: GOVERNANCE allows administrators to delete if needed (e.g., GDPR right to erasure),
   while still protecting against accidental or malicious deletion. COMPLIANCE mode
   is truly immutable - even AWS Support cannot delete.

Q: What happens when versioning is disabled?
A: Object Lock REQUIRES versioning. Without versioning, you cannot use Object Lock.
   Each version gets its own retention settings.

Q: How do you handle GDPR right to erasure with Object Lock?
A: Use GOVERNANCE mode so authorized admins can delete. Or use client-side
   encryption and delete the KMS key - the data becomes cryptographically erased.

## Pidgin Explanation
Object Lock be like say you dey put paper for safe with time lock:
- Compliance mode = even bank manager no fit open before time
- Governance mode = bank manager fit open but e go leave record
- Training data stay clean because nobody fit edit am without trace
