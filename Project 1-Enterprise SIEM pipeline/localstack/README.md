# LocalStack Configuration

## Overview
LocalStack provides a local AWS cloud stack for testing the SIEM pipeline without incurring any AWS costs.

## Quick Start
```bash
# From project root
docker-compose up -d
./localstack/setup-localstack.sh
```

## Available Services
- S3: http://localhost:4566
- Kinesis: http://localhost:4566
- Lambda: http://localhost:4566
- KMS: http://localhost:4566
- EventBridge: http://localhost:4566

## Testing
```bash
# Verify services
curl http://localhost:4566/_localstack/health | jq

# List resources
awslocal s3 ls
awslocal kinesis list-streams
```
