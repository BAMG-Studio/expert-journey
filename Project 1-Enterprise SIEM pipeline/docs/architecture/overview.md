# SIEM Pipeline Architecture Overview

## Data Flow

```
AWS Security Services --> EventBridge --> Lambda Normalizers --> Kinesis Firehose --> OpenSearch
                                                                                 --> S3 Archive
```

## Components

### Data Sources (Input)
1. **CloudTrail** - Records every AWS API call
2. **GuardDuty** - ML-based threat detection
3. **Security Hub** - Aggregated security findings
4. **VPC Flow Logs** - Network traffic metadata
5. **Macie** - S3 data classification

### Processing Layer
1. **EventBridge** - Routes events to correct normalizer
2. **Lambda Normalizers** - Transforms diverse formats to NIST AU-3 schema
3. **Context Enricher** - Adds account aliases and resource tags

### Storage & Analytics
1. **Kinesis Firehose** - Buffers and delivers to OpenSearch
2. **OpenSearch** - Full-text search and SIEM dashboards
3. **S3 Log Archive** - Long-term retention with lifecycle policies

### Security
1. **KMS** - Customer-managed encryption keys
2. **IAM** - Least-privilege roles per component
3. **VPC** - Network isolation for OpenSearch

## Design Principles

- **Defense in Depth**: Multiple layers of security
- **Least Privilege**: Minimal IAM permissions per service
- **Encryption Everywhere**: KMS encryption at rest and in transit
- **Cost Optimization**: Intelligent tiering, LocalStack for dev
- **Compliance Ready**: NIST, SOC 2, PCI DSS compatible
