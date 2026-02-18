# Security Best Practices

## Encryption
- All data encrypted at rest with KMS (customer-managed keys)
- All data encrypted in transit (TLS 1.2+)
- S3 bucket keys enabled (reduces KMS cost by 99%)

## Access Control
- IAM roles follow least-privilege principle
- No hardcoded credentials anywhere
- OpenSearch fine-grained access control enabled
- S3 public access blocked on all buckets

## Network Security
- OpenSearch deployed in VPC (production)
- Security groups restrict access by CIDR
- No public endpoints for backend services

## Monitoring
- CloudWatch alarms on Lambda errors
- Firehose delivery failure alerts
- OpenSearch cluster health monitoring

## Compliance
- Log retention meets SOC 2 requirements (365 days)
- Audit trail maintained via CloudTrail
- All changes tracked through Terraform state
