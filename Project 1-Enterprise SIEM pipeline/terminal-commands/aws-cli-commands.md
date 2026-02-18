# AWS CLI Commands

## Auth
```bash
aws configure
aws sts get-caller-identity
```

## S3
```bash
aws s3 ls
aws s3 ls s3://enterprise-siem-logs/ --recursive
aws s3 cp s3://enterprise-siem-logs/cloudtrail/ ./logs/ --recursive
```

## Lambda
```bash
aws lambda list-functions --query "Functions[?contains(FunctionName,"siem")]"
aws lambda invoke --function-name siem-dev-guardduty-normalizer --payload file://test.json out.json
aws logs tail /aws/lambda/siem-dev-guardduty-normalizer --follow
```

## Kinesis
```bash
aws firehose list-delivery-streams
aws firehose describe-delivery-stream --delivery-stream-name siem-stream
```

## OpenSearch
```bash
aws opensearch list-domain-names
aws opensearch describe-domain --domain-name siem-dev
```

## CloudTrail & GuardDuty
```bash
aws cloudtrail describe-trails
aws guardduty list-detectors
aws guardduty list-findings --detector-id ID
```

## Cost
```bash
aws ce get-cost-and-usage --time-period Start=2026-02-01,End=2026-02-28 --granularity MONTHLY --metrics UnblendedCost
```
