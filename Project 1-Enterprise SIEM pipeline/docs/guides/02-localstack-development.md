# LocalStack Development Guide

## What is LocalStack?

LocalStack is a fully functional local AWS cloud stack that allows you to develop and test your cloud applications offline, without incurring any AWS costs.

## Supported Services

Our SIEM pipeline uses these LocalStack services:
- S3 (Log Archive)
- Kinesis Firehose (Data Streaming)
- Lambda (Event Processing)
- IAM (Access Control)
- KMS (Encryption)
- CloudWatch Logs
- EventBridge

## Starting LocalStack

```bash
# Start all services
docker-compose up -d

# Verify health
curl http://localhost:4566/_localstack/health | jq
```

## Using awslocal CLI

```bash
# Install awslocal
pip install awscli-local

# Use instead of aws cli
awslocal s3 ls
awslocal lambda list-functions
awslocal kinesis list-streams
```

## Testing Lambda Functions

```bash
# Package Lambda
cd lambda/normalizers
zip -r function.zip *.py

# Create function
awslocal lambda create-function   --function-name test-normalizer   --runtime python3.11   --handler guardduty_normalizer.lambda_handler   --zip-file fileb://function.zip   --role arn:aws:iam::000000000000:role/lambda-role

# Invoke
awslocal lambda invoke   --function-name test-normalizer   --payload file://../../tests/fixtures/guardduty-event.json   output.json
```

## Limitations

- OpenSearch is run separately (not in LocalStack)
- GuardDuty/Security Hub not fully supported
- Some IAM policies may behave differently
