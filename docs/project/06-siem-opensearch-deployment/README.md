# SIEM OpenSearch Deployment

## Overview

> **Mentor Note**: A SIEM (Security Information and Event Management) is like a security command center that collects logs from every system in your organization, correlates them to find patterns, and alerts when something suspicious happens. OpenSearch is the open-source engine that powers this analysis at scale.

This project deploys a production-grade SIEM solution using Amazon OpenSearch Service. It ingests security logs from CloudTrail, VPC Flow Logs, GuardDuty, WAF, and application sources, provides real-time threat detection dashboards, and enables security analysts to hunt for threats across the entire environment.

### Why This Matters

- Centralized visibility across all security data sources
- Real-time correlation of events across services
- Compliance requirement for log retention and analysis
- Enables proactive threat hunting beyond automated detection

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  CloudTrail      |     |                  |     |                  |
|  VPC Flow Logs   |---->|  Kinesis Data    |---->|  OpenSearch      |
|  GuardDuty       |     |  Firehose        |     |  Domain          |
|  WAF Logs        |     |                  |     |                  |
|  App Logs        |     |  (Transform +    |     |  (3 master +     |
+------------------+     |   Buffer)        |     |   6 data nodes)  |
                          +------------------+     +------------------+
                                                         |
                                                         v
                                                  +------------------+
                                                  |  OpenSearch      |
                                                  |  Dashboards      |
                                                  |  (Visualization) |
                                                  +------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Log Ingestion | Kinesis Data Firehose | Buffer and transform log streams |
| Search/Analytics | OpenSearch Service | Index, search, and analyze logs |
| Visualization | OpenSearch Dashboards | Security dashboards and alerts |
| Storage | S3 (cold tier) | Long-term log retention |
| Alerting | OpenSearch Alerting plugin | Automated threat notifications |
| Auth | Cognito + IAM | Access control for dashboards |

---

## Core Concepts

### Log Sources and Index Patterns

| Source | Index Pattern | Retention | Use Case |
|--------|--------------|----------|----------|
| CloudTrail | `cloudtrail-*` | 90 days hot, 1 year warm | API activity auditing |
| VPC Flow Logs | `vpcflow-*` | 30 days hot | Network traffic analysis |
| GuardDuty | `guardduty-*` | 365 days | Threat detection findings |
| WAF | `waf-*` | 90 days | Web attack analysis |
| Application | `app-*` | 30 days | Application security events |

### OpenSearch Cluster Sizing

| Workload | Data Nodes | Instance Type | Storage |
|----------|-----------|--------------|----------|
| Small (< 100 GB/day) | 3 | r6g.large | 500 GB EBS each |
| Medium (100-500 GB/day) | 6 | r6g.xlarge | 1 TB EBS each |
| Large (> 500 GB/day) | 9+ | r6g.2xlarge | 2 TB EBS each |

---

## Implementation Guide

### Step 1: OpenSearch Domain (Terraform)

```hcl
resource "aws_opensearch_domain" "siem" {
  domain_name    = "security-siem"
  engine_version = "OpenSearch_2.11"
  
  cluster_config {
    instance_type            = "r6g.xlarge.search"
    instance_count           = 6
    dedicated_master_enabled = true
    dedicated_master_type    = "r6g.large.search"
    dedicated_master_count   = 3
    zone_awareness_enabled   = true
    zone_awareness_config {
      availability_zone_count = 3
    }
  }
  
  ebs_options {
    ebs_enabled = true
    volume_size = 1000
    volume_type = "gp3"
  }
  
  encrypt_at_rest { enabled = true }
  node_to_node_encryption { enabled = true }
  
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
  }
}
```

### Step 2: Log Ingestion Pipeline

```python
import boto3
import json

def setup_firehose_delivery(log_source, index_prefix):
    """Create Kinesis Firehose delivery stream for OpenSearch."""
    firehose = boto3.client("firehose")
    
    firehose.create_delivery_stream(
        DeliveryStreamName=f"siem-{log_source}",
        DeliveryStreamType="DirectPut",
        AmazonopensearchserviceDestinationConfiguration={
            "RoleARN": FIREHOSE_ROLE_ARN,
            "DomainARN": OPENSEARCH_DOMAIN_ARN,
            "IndexName": index_prefix,
            "IndexRotationPeriod": "OneDay",
            "BufferingHints": {
                "IntervalInSeconds": 60,
                "SizeInMBs": 5
            },
            "RetryOptions": {"DurationInSeconds": 300},
            "S3BackupMode": "AllDocuments",
            "S3Configuration": {
                "RoleARN": FIREHOSE_ROLE_ARN,
                "BucketARN": S3_BACKUP_BUCKET_ARN
            }
        }
    )
```

### Step 3: Security Detection Rules

```json
{
  "name": "Unauthorized API Call from New IP",
  "type": "monitor",
  "enabled": true,
  "schedule": {"period": {"interval": 5, "unit": "MINUTES"}},
  "inputs": [{
    "search": {
      "indices": ["cloudtrail-*"],
      "query": {
        "bool": {
          "must": [
            {"term": {"errorCode.keyword": "AccessDenied"}},
            {"range": {"@timestamp": {"gte": "now-5m"}}}
          ],
          "must_not": [
            {"terms": {"sourceIPAddress.keyword": ["KNOWN_IP_LIST"]}}
          ]
        }
      }
    }
  }],
  "triggers": [{
    "name": "Unauthorized access alert",
    "severity": "2",
    "condition": {"script": {"source": "ctx.results[0].hits.total.value > 5"}}
  }]
}
```

---

## Deployment

### Prerequisites

- AWS Account with OpenSearch, Kinesis, Cognito access
- VPC with private subnets
- Terraform 1.5+

### Quick Start

```bash
# Deploy OpenSearch domain
cd terraform/siem
terraform apply

# Configure index templates
python setup_indices.py --domain security-siem

# Import dashboards
python import_dashboards.py --file dashboards/security-overview.ndjson
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Check cluster health | `curl -XGET https://DOMAIN/_cluster/health` |
| List indices | `curl -XGET https://DOMAIN/_cat/indices?v` |
| Search logs | `curl -XGET https://DOMAIN/cloudtrail-*/_search` |
| Check shard allocation | `curl -XGET https://DOMAIN/_cat/shards?v` |

### Links
- [Amazon OpenSearch Service](https://docs.aws.amazon.com/opensearch-service/)
- [OpenSearch Documentation](https://opensearch.org/docs/latest/)
- [SIEM on Amazon OpenSearch](https://github.com/aws-samples/siem-on-amazon-opensearch-service)
