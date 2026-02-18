# AWS CLI Commands Reference for SIEM Pipeline

## S3 - Log Archive Operations
```bash
# List all buckets
aws s3 ls

# List log archive contents
aws s3 ls s3://siem-log-archive-dev/ --recursive

# Copy a log file locally for inspection
aws s3 cp s3://siem-log-archive-dev/cloudtrail/2024/01/log.json ./local-log.json

# Check bucket encryption status
aws s3api get-bucket-encryption --bucket siem-log-archive-dev
```

## CloudTrail
```bash
# Check trail status
aws cloudtrail get-trail-status --name siem-cloudtrail

# Look up recent events
aws cloudtrail lookup-events --max-results 10
```

## KMS - Encryption Keys
```bash
# List all KMS keys
aws kms list-keys

# Describe the SIEM encryption key
aws kms describe-key --key-id alias/siem-encryption-key
```

## Lambda
```bash
# List SIEM Lambda functions
aws lambda list-functions --query 'Functions[?starts_with(FunctionName, `siem-`)]'

# Invoke normalizer manually for testing
aws lambda invoke --function-name siem-vpc-flowlog-normalizer --payload file://test-event.json output.json

# View Lambda logs
aws logs tail /aws/lambda/siem-vpc-flowlog-normalizer --follow
```

## LocalStack Equivalent
```bash
# Same commands but with --endpoint-url
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 lambda list-functions
```
