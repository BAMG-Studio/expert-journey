# Serverless Data Pipeline

## Overview

> **Mentor Note**: A data pipeline is like a factory assembly line for information. Raw data comes in, gets cleaned, transformed, and assembled into useful products (reports, dashboards, ML features). Making it serverless means the factory scales automatically and you only pay when the line is running.

This project implements an event-driven serverless data pipeline using AWS Lambda, Step Functions, S3, and Glue. It processes streaming and batch data for analytics, ML feature engineering, and real-time dashboarding with zero infrastructure management.

### Why This Matters

- Eliminates server management and capacity planning
- Scales automatically from zero to millions of events
- Pay-per-use pricing reduces costs for variable workloads
- Event-driven architecture enables real-time data processing

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  Data Sources    |     |  Ingestion       |     |  Processing      |
|  - S3 uploads    |---->|  - EventBridge   |---->|  - Lambda        |
|  - API Gateway   |     |  - SQS queues    |     |  - Step Functions|
|  - Kinesis       |     |  - S3 events     |     |  - Glue ETL      |
+------------------+     +------------------+     +------------------+
                                                         |
                                                         v
+------------------+     +------------------+     +------------------+
|  Consumption     |<----|  Storage         |<----|  Transformation  |
|  - Athena        |     |  - S3 (Parquet)  |     |  - Data Quality  |
|  - QuickSight    |     |  - DynamoDB      |     |  - Schema Valid  |
|  - API           |     |  - Redshift      |     |  - Enrichment    |
+------------------+     +------------------+     +------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Ingestion | EventBridge + SQS | Event-driven data collection |
| Processing | Lambda + Step Functions | Transform and validate data |
| ETL | AWS Glue | Heavy batch transformations |
| Storage | S3 (Parquet) + DynamoDB | Optimized data storage |
| Catalog | Glue Data Catalog | Schema management |
| Query | Athena | Serverless SQL analytics |

---

## Core Concepts

### Data Lake Zones

| Zone | Format | Purpose |
|------|--------|----------|
| **Raw (Bronze)** | Original format | Immutable landing zone |
| **Cleaned (Silver)** | Parquet, validated | Deduplicated, schema-enforced |
| **Curated (Gold)** | Aggregated Parquet | Business-ready analytics |

### Event-Driven vs Batch Processing

| Approach | Latency | Use Case |
|----------|---------|----------|
| **Event-Driven** | Seconds | Real-time alerts, live dashboards |
| **Micro-Batch** | Minutes | Near-real-time analytics |
| **Batch** | Hours | Historical analysis, ML training |

---

## Implementation Guide

### Step 1: S3 Event-Driven Ingestion

```python
import json
import boto3
import pyarrow.parquet as pq

def process_s3_event(event, context):
    """Process files uploaded to S3 raw zone."""
    s3 = boto3.client("s3")
    
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
        
        # Download and validate
        obj = s3.get_object(Bucket=bucket, Key=key)
        data = json.loads(obj["Body"].read())
        
        # Validate schema
        validated = validate_schema(data)
        
        # Transform and write to silver zone
        transformed = transform_data(validated)
        write_parquet_to_s3(
            transformed,
            bucket="data-lake-silver",
            key=f"processed/{get_partition_key()}/{key}.parquet"
        )
```

### Step 2: Step Functions Orchestration

```json
{
  "StartAt": "ValidateData",
  "States": {
    "ValidateData": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:REGION:ACCOUNT:function:validate-data",
      "Next": "DataQualityCheck"
    },
    "DataQualityCheck": {
      "Type": "Choice",
      "Choices": [{
        "Variable": "$.quality_score",
        "NumericGreaterThan": 0.95,
        "Next": "TransformData"
      }],
      "Default": "QuarantineData"
    },
    "TransformData": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:REGION:ACCOUNT:function:transform-data",
      "Next": "LoadToGold"
    },
    "LoadToGold": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:REGION:ACCOUNT:function:load-gold",
      "End": true
    }
  }
}
```

### Step 3: Athena Query Layer

```sql
-- Create external table over S3 data
CREATE EXTERNAL TABLE gold.daily_metrics (
    date_key      DATE,
    metric_name   STRING,
    metric_value  DOUBLE,
    dimensions    MAP<STRING, STRING>
)
PARTITIONED BY (year INT, month INT, day INT)
STORED AS PARQUET
LOCATION "s3://data-lake-gold/daily_metrics/";

-- Query with partition pruning
SELECT metric_name, AVG(metric_value) as avg_value
FROM gold.daily_metrics
WHERE year = 2024 AND month = 1
GROUP BY metric_name;
```

---

## Deployment

### Prerequisites

- AWS Account with Lambda, Step Functions, S3, Glue, Athena
- Terraform 1.5+
- Python 3.11+

### Quick Start

```bash
# Deploy pipeline infrastructure
cd terraform/data-pipeline
terraform apply

# Upload test data
aws s3 cp test-data.json s3://data-lake-raw/incoming/

# Query processed data
aws athena start-query-execution --query-string "SELECT * FROM gold.daily_metrics LIMIT 10"
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Trigger pipeline | `aws s3 cp data.json s3://data-lake-raw/incoming/` |
| Check Step Functions | `aws stepfunctions list-executions --state-machine-arn <arn>` |
| Run Athena query | `aws athena start-query-execution --query-string "..."` |
| View Glue catalog | `aws glue get-tables --database-name gold` |

### Links
- [AWS Serverless Data Lake](https://aws.amazon.com/solutions/implementations/data-lake-solution/)
- [AWS Lambda](https://docs.aws.amazon.com/lambda/)
- [AWS Glue](https://docs.aws.amazon.com/glue/)
