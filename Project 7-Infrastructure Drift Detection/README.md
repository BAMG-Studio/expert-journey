# Infrastructure Drift Detection

**A real-time infrastructure drift detection and automated remediation platform that continuously monitors cloud resources against desired state configurations, identifies unauthorized changes, and enforces infrastructure-as-code compliance across multi-cloud environments.**

## Architecture Overview

This project implements a continuous drift detection system that compares live cloud infrastructure state against Terraform state files, CloudFormation stacks, and organizational baselines. It uses event-driven architecture to detect changes in near real-time, classifies drift severity, and triggers automated or approval-gated remediation workflows.

### Core Components

- **Drift Scanner** - Scheduled and event-driven infrastructure state comparison engine supporting AWS, Azure, and GCP
- **Change Classifier** - ML-powered classification of drift events by severity, intent, and risk level
- **Real-Time Event Processor** - CloudTrail/EventBridge stream processor for near-instant drift detection
- **Remediation Orchestrator** - Automated rollback and remediation with approval workflows for high-risk changes
- **Baseline Manager** - Golden configuration management with version-controlled infrastructure baselines
- **Forensics Engine** - Attribution and timeline reconstruction for unauthorized infrastructure changes
- **Compliance Reporter** - Drift trend analysis, compliance scoring, and executive reporting

### Technology Stack

| Component | Technology |
|-----------|------------|
| Drift Detection | Terraform, Driftctl, custom Python scanners |
| Event Processing | AWS EventBridge, CloudTrail, Kinesis |
| Stream Processing | Apache Kafka, AWS Lambda |
| State Management | S3, DynamoDB, Terraform Cloud |
| Classification | scikit-learn, rule engine |
| Remediation | Terraform, AWS Systems Manager, Ansible |
| Monitoring | Prometheus, Grafana, CloudWatch |
| Notification | Slack, PagerDuty, SNS, OpsGenie |
| Database | PostgreSQL, TimescaleDB (time-series) |
| CI/CD | GitHub Actions |

## Drift Detection Capabilities

| Resource Type | Detection Method | Latency | Auto-Remediate |
|--------------|-----------------|---------|----------------|
| IAM Policies/Roles | EventBridge + CloudTrail | < 1 min | Yes (critical) |
| Security Groups | EventBridge real-time | < 1 min | Yes |
| S3 Bucket Policies | EventBridge + scheduled | < 5 min | Yes |
| EC2 Instances | Scheduled scan | 15 min | No (approval) |
| RDS Configuration | Scheduled scan | 15 min | No (approval) |
| VPC/Networking | EventBridge + scheduled | < 5 min | Yes (select) |
| Lambda Functions | EventBridge real-time | < 1 min | Yes |
| KMS Key Policies | EventBridge + CloudTrail | < 1 min | Yes |
| EKS Cluster Config | Scheduled scan | 30 min | No (approval) |
| CloudFront Distributions | Scheduled scan | 30 min | No (approval) |

## Prerequisites

- Python >= 3.10
- Terraform >= 1.5.0
- Driftctl >= 0.40.0
- AWS account with CloudTrail enabled
- Docker >= 24.0
- PostgreSQL >= 14

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 7-Infrastructure Drift Detection"

# Install dependencies
pip install -r requirements.txt

# Configure AWS credentials
aws configure --profile drift-detector

# Configure environment
cp .env.example .env

# Start infrastructure
docker-compose up -d
```

### 2. Initialize Baselines

```bash
# Import current Terraform state as baseline
python baseline/import_state.py --source s3://my-tf-state/prod/terraform.tfstate

# Scan current infrastructure
python scanner/full_scan.py --profile prod --regions us-east-1,us-west-2

# Establish golden baseline
python baseline/create_golden.py --from-scan latest --approve
```

### 3. Enable Continuous Monitoring

```bash
# Deploy EventBridge rules for real-time detection
python deploy/eventbridge_rules.py --regions us-east-1,us-west-2

# Start drift detection daemon
python scanner/daemon.py --mode continuous --interval 15m

# Start remediation engine
python remediation/engine.py --daemon --approval-mode auto-critical
```

## Project Structure

```
Project 7-Infrastructure Drift Detection/
|-- scanner/
|   |-- full_scan.py              # Full infrastructure scan
|   |-- daemon.py                 # Continuous scanning daemon
|   |-- providers/
|   |   |-- aws_scanner.py        # AWS resource scanner
|   |   |-- azure_scanner.py      # Azure resource scanner
|   |   |-- gcp_scanner.py        # GCP resource scanner
|   |-- comparators/              # State comparison logic
|-- event_processor/
|   |-- cloudtrail_handler.py     # CloudTrail event processor
|   |-- eventbridge_handler.py    # EventBridge event handler
|   |-- stream_processor.py       # Kinesis/Kafka stream processor
|   |-- lambda_functions/         # AWS Lambda event handlers
|-- classifier/
|   |-- drift_classifier.py       # Drift severity classifier
|   |-- ml_model/                 # ML classification model
|   |-- rules/                    # Rule-based classification
|-- remediation/
|   |-- engine.py                 # Remediation orchestrator
|   |-- strategies/               # Remediation strategies
|   |-- approval_workflow.py      # Approval gate manager
|   |-- rollback.py               # State rollback engine
|-- baseline/
|   |-- import_state.py           # State import utility
|   |-- create_golden.py          # Golden baseline creator
|   |-- version_manager.py        # Baseline version control
|-- forensics/
|   |-- attribution.py            # Change attribution engine
|   |-- timeline.py               # Event timeline builder
|   |-- report_generator.py       # Forensic report generator
|-- deploy/
|   |-- eventbridge_rules.py      # EventBridge rule deployment
|   |-- terraform/                # Infrastructure for drift detector
|-- dashboard/
|   |-- grafana/                  # Grafana dashboard configs
|   |-- compliance_reports/       # Report templates
|-- tests/
|   |-- unit/                     # Unit tests
|   |-- integration/              # Integration tests
|   |-- simulation/               # Drift simulation tests
|-- .github/
|   |-- workflows/                # CI/CD pipeline definitions
|-- docker-compose.yml
|-- requirements.txt
|-- README.md
```

## Drift Response Workflow

1. **Detection** - Drift identified via real-time event or scheduled scan
2. **Classification** - Severity and intent classified (accidental, malicious, authorized)
3. **Notification** - Alert sent to appropriate team via Slack/PagerDuty
4. **Attribution** - CloudTrail analysis identifies who/what made the change
5. **Decision** - Auto-remediate (critical security) or await approval
6. **Remediation** - Terraform apply or SSM runbook execution
7. **Verification** - Post-remediation scan confirms drift resolved
8. **Documentation** - Full event logged for compliance audit trail

## Cost Estimates

| Environment | Monthly Cost |
|-------------|-------------|
| Local Development | $0 (Docker) |
| Single Account | ~$100-300 |
| Multi-Account Enterprise | ~$500-2,000 |

## License

MIT License
