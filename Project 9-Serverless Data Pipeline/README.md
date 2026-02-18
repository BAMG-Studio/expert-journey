# Serverless Data Pipeline

**A fully serverless, event-driven data pipeline platform built on AWS Lambda, Step Functions, and managed services that ingests, transforms, validates, and loads data at scale with built-in observability, error handling, and cost optimization.**

## Architecture Overview

This project implements a production-grade serverless data pipeline that processes structured and semi-structured data from multiple sources through configurable transformation stages. It leverages AWS Step Functions for orchestration, Lambda for compute, and managed services for storage and analytics, achieving zero-server management with automatic scaling and pay-per-execution pricing.

### Core Components

- **Ingestion Layer** - Multi-source data ingestion from S3, Kinesis, SQS, API Gateway, and DynamoDB Streams
- **Transformation Engine** - Configurable data transformation pipeline using Lambda functions with Pandas and PySpark on Glue
- **Validation Framework** - Schema validation, data quality checks, and anomaly detection using Great Expectations
- **Orchestration** - AWS Step Functions state machines with error handling, retry logic, and parallel execution
- **Data Catalog** - AWS Glue Data Catalog integration with automated schema discovery and versioning
- **Analytics Layer** - Athena query integration with pre-built analytical views and Redshift Serverless loading
- **Observability Stack** - End-to-end pipeline monitoring with CloudWatch, X-Ray tracing, and custom dashboards

### Technology Stack

| Component | Technology |
|-----------|------------|
| Compute | AWS Lambda (Python 3.12), Glue ETL |
| Orchestration | AWS Step Functions, EventBridge Scheduler |
| Ingestion | Kinesis Data Streams, SQS, S3 Events |
| Storage | S3 (data lake), DynamoDB (metadata) |
| Data Format | Parquet, Avro, JSON, CSV |
| Catalog | AWS Glue Data Catalog |
| Analytics | Athena, Redshift Serverless, QuickSight |
| Validation | Great Expectations, custom validators |
| Monitoring | CloudWatch, X-Ray, custom metrics |
| IaC | Terraform, AWS SAM |
| CI/CD | GitHub Actions |

## Pipeline Stages

| Stage | Lambda Function | Timeout | Memory | Concurrency |
|-------|----------------|---------|--------|-------------|
| Ingest | data_ingester | 5 min | 512 MB | 100 |
| Validate | schema_validator | 3 min | 256 MB | 50 |
| Transform | data_transformer | 10 min | 1024 MB | 50 |
| Enrich | data_enricher | 5 min | 512 MB | 25 |
| Quality Check | quality_checker | 5 min | 512 MB | 25 |
| Load | data_loader | 10 min | 1024 MB | 25 |
| Catalog | catalog_updater | 2 min | 256 MB | 10 |
| Notify | notification_handler | 1 min | 128 MB | 10 |

## Prerequisites

- AWS account with appropriate IAM permissions
- Python >= 3.12
- Terraform >= 1.5.0
- AWS SAM CLI >= 1.90.0
- Docker >= 24.0 (for local Lambda testing)
- Node.js >= 18 (for CDK constructs)

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 9-Serverless Data Pipeline"

# Install dependencies
pip install -r requirements.txt

# Configure AWS credentials
aws configure --profile data-pipeline

# Configure environment
cp .env.example .env
```

### 2. Deploy Infrastructure

```bash
# Initialize Terraform
cd terraform
terraform init -backend-config=environments/dev.tfvars

# Deploy pipeline infrastructure
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars

# Deploy Lambda functions
cd ../lambdas
sam build
sam deploy --guided
```

### 3. Run Pipeline

```bash
# Trigger pipeline with sample data
python trigger/run_pipeline.py --source s3://my-bucket/raw/sample.csv --config configs/default.yml

# Monitor execution
python monitoring/watch.py --execution-id latest

# Query results
python analytics/query.py --sql "SELECT * FROM processed_data LIMIT 10"
```

## Project Structure

```
Project 9-Serverless Data Pipeline/
|-- lambdas/
|   |-- ingester/                 # Data ingestion function
|   |-- validator/                # Schema validation function
|   |-- transformer/              # Data transformation function
|   |-- enricher/                 # Data enrichment function
|   |-- quality_checker/          # Data quality check function
|   |-- loader/                   # Data loading function
|   |-- cataloger/                # Catalog update function
|   |-- notifier/                 # Notification handler
|   |-- layers/                   # Shared Lambda layers
|-- step_functions/
|   |-- definitions/              # State machine definitions (ASL)
|   |-- pipeline_standard.json    # Standard processing pipeline
|   |-- pipeline_streaming.json   # Real-time streaming pipeline
|   |-- pipeline_batch.json       # Batch processing pipeline
|-- configs/
|   |-- default.yml               # Default pipeline config
|   |-- transformations/          # Transformation rule configs
|   |-- schemas/                  # Data schema definitions
|   |-- quality_rules/            # Great Expectations suites
|-- terraform/
|   |-- modules/
|   |   |-- lambda/               # Lambda function module
|   |   |-- step_functions/       # Step Functions module
|   |   |-- data_lake/            # S3 data lake module
|   |   |-- monitoring/           # Observability module
|   |-- environments/             # Environment-specific configs
|-- analytics/
|   |-- queries/                  # Pre-built Athena queries
|   |-- views/                    # Analytical view definitions
|   |-- query.py                  # Query execution utility
|-- monitoring/
|   |-- dashboards/               # CloudWatch dashboard configs
|   |-- alarms/                   # CloudWatch alarm definitions
|   |-- watch.py                  # Pipeline execution monitor
|-- trigger/
|   |-- run_pipeline.py           # Pipeline trigger utility
|   |-- schedule_manager.py       # Scheduled execution manager
|-- tests/
|   |-- unit/                     # Unit tests
|   |-- integration/              # Integration tests
|   |-- local/                    # Local SAM testing
|-- .github/
|   |-- workflows/                # CI/CD pipeline definitions
|-- requirements.txt
|-- template.yaml                 # SAM template
|-- README.md
```

## Pipeline Patterns

1. **Batch Processing** - Scheduled S3 file processing (daily/hourly)
2. **Real-Time Streaming** - Kinesis stream processing with sub-second latency
3. **Event-Driven** - S3 event triggers for on-demand processing
4. **API-Triggered** - REST API endpoint for on-demand pipeline execution
5. **Fan-Out** - Parallel processing of multiple data sources with aggregation

## Data Quality Checks

```yaml
# Example Great Expectations suite
expectations:
  - expect_column_to_exist: ["user_id", "timestamp", "event_type"]
  - expect_column_values_to_not_be_null: ["user_id"]
  - expect_column_values_to_be_between:
      column: "amount"
      min_value: 0
      max_value: 1000000
  - expect_column_values_to_be_unique: ["transaction_id"]
```

## Cost Estimates

| Workload | Monthly Cost |
|----------|-------------|
| Dev (1K executions/day) | ~$5-20 |
| Staging (10K exec/day) | ~$50-150 |
| Production (100K exec/day) | ~$300-1,000 |
| High-Volume (1M exec/day) | ~$1,500-5,000 |

## License

MIT License
