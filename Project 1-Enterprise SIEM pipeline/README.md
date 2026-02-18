# Enterprise SIEM Pipeline

**A complete Security Information and Event Management (SIEM) solution built on AWS**

## Architecture Overview

```
+------------------+     +------------------+     +-------------------+
|   CloudTrail     |     |    GuardDuty     |     |   Security Hub    |
|  (API Logging)   |     | (Threat Detection)|     | (Finding Agg.)    |
+--------+---------+     +--------+---------+     +---------+---------+
         |                        |                         |
         v                        v                         v
+--------+------------------------+-------------------------+---------+
|                         EventBridge                                  |
|                    (Event Routing & Filtering)                       |
+--------+------------------------+-------------------------+---------+
         |                        |                         |
         v                        v                         v
+--------+---------+     +--------+---------+     +---------+---------+
| CloudTrail       |     |  GuardDuty       |     |  SecurityHub      |
| Normalizer       |     |  Normalizer      |     |  Normalizer       |
| (Lambda)         |     |  (Lambda)        |     |  (Lambda)         |
+--------+---------+     +--------+---------+     +---------+---------+
         |                        |                         |
         +------------------------+-------------------------+
                                  |
                                  v
+-------------------------------------------------------------------------+
|                      Kinesis Firehose                                   |
|                  (Buffering & Delivery)                                 |
+-------------------------------------+-----------------------------------+
                                      |
              +-----------------------+------------------------+
              |                                                |
              v                                                v
+-------------+--------------+               +-----------------+-----------+
|        OpenSearch          |               |           S3                |
| (Search & Visualization)   |               |   (Long-term Archive)       |
+----------------------------+               +-----------------------------+
```

## Quick Start

### 1. Local Development with LocalStack (Zero AWS Cost)

```bash
# Start LocalStack and OpenSearch
docker-compose up -d

# Initialize Terraform with LocalStack
cd terraform
terraform init
terraform apply -var-file=environments/localstack.tfvars

# Access SIEM Dashboard
open http://localhost:5601
```

### 2. Deploy to AWS (Development)

```bash
# Configure AWS credentials
aws configure

# Set OpenSearch password
export TF_VAR_opensearch_master_password="YourSecure@Password123"

# Deploy
cd terraform
terraform init
terraform apply -var-file=environments/dev.tfvars
```

## Project Structure

```
Project 1-Enterprise SIEM pipeline/
|-- TERRAFORM_DESTROY.sh    # Manual destroy script (DANGER)
|-- docker-compose.yml      # Local development environment
|-- README.md               # This file
|
|-- terraform/              # Infrastructure as Code
|   |-- main.tf             # Root module
|   |-- variables.tf        # Input variables
|   |-- providers.tf        # AWS provider config
|   |-- environments/       # Environment-specific configs
|   |   |-- dev.tfvars
|   |   |-- localstack.tfvars
|   |   |-- prod.tfvars.template
|   |-- modules/            # Reusable Terraform modules
|       |-- kms/            # Encryption keys
|       |-- s3-log-archive/ # Log storage
|       |-- opensearch/     # SIEM search engine
|       |-- kinesis-firehose/ # Data streaming
|       |-- cloudtrail/     # API logging
|       |-- eventbridge/    # Event routing
|       |-- lambda-normalizers/ # Event processing
|
|-- lambda/                 # Lambda function code
|   |-- normalizers/        # Event normalization functions
|       |-- guardduty_normalizer.py
|       |-- cloudtrail_normalizer.py
|       |-- securityhub_normalizer.py
|-- docs/                   # Additional documentation
```

## Terraform Commands

| Command | Description |
|---------|-------------|
| terraform init | Initialize working directory |
| terraform plan | Preview changes |
| terraform apply | Apply changes |
| terraform destroy | **DANGER** Destroy all resources |

## Destroying Resources

**IMPORTANT**: Use the provided destroy script for safe teardown:

```bash
chmod +x TERRAFORM_DESTROY.sh
./TERRAFORM_DESTROY.sh
```

This script includes safety measures:
- Requires confirmation phrase
- Creates state backup
- 30-second countdown
- Cannot run in CI/CD

## Cost Estimates

| Environment | Monthly Cost |
|-------------|-------------|
| LocalStack  | \$0 (local) |
| Dev (minimal) | ~\$50-100 |
| Production  | ~\$500-2000 |

## License

MIT License
