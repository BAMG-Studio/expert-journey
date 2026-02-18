# FedRAMP Compliance Automation

**An end-to-end compliance-as-code framework that automates FedRAMP authorization workflows, continuous monitoring, and audit evidence generation across AWS GovCloud environments.**

## Architecture Overview

This project implements a fully automated FedRAMP compliance pipeline that maps NIST 800-53 controls to infrastructure configurations, generates System Security Plans (SSP) programmatically, and maintains continuous authorization through real-time drift detection and automated remediation.

### Core Components

- **Control Mapping Engine** - Maps NIST 800-53 Rev 5 controls to Terraform resources and AWS service configurations
- **SSP Generator** - Auto-generates System Security Plan documentation from live infrastructure state
- **POA&M Tracker** - Plan of Action and Milestones management with automated status updates
- **Continuous Monitoring Dashboard** - Real-time compliance posture visualization with Grafana
- **Evidence Collector** - Automated screenshot, log, and configuration snapshot collection for audit packages
- **Remediation Engine** - Auto-remediation of compliance drift with approval workflows

### Technology Stack

| Component | Technology |
|-----------|------------|
| Infrastructure as Code | Terraform, AWS CloudFormation |
| Policy Engine | Open Policy Agent (OPA), AWS Config Rules |
| CI/CD Pipeline | GitHub Actions, AWS CodePipeline |
| Monitoring | AWS SecurityHub, CloudWatch, Grafana |
| Documentation | Python (Jinja2 templates), Markdown |
| Data Store | DynamoDB, S3 (evidence artifacts) |
| Notification | SNS, Slack webhooks |
| Container Runtime | Docker, ECS Fargate |

## FedRAMP Control Families Covered

| Control Family | ID | Controls Automated | Coverage |
|---------------|-----|-------------------|----------|
| Access Control | AC | AC-1 through AC-22 | 95% |
| Audit & Accountability | AU | AU-1 through AU-16 | 90% |
| Configuration Management | CM | CM-1 through CM-11 | 92% |
| Identification & Auth | IA | IA-1 through IA-11 | 88% |
| System & Comms Protection | SC | SC-1 through SC-39 | 85% |
| System & Info Integrity | SI | SI-1 through SI-16 | 90% |
| Incident Response | IR | IR-1 through IR-10 | 87% |
| Risk Assessment | RA | RA-1 through RA-5 | 93% |

## Prerequisites

- AWS GovCloud account with appropriate IAM permissions
- Terraform >= 1.5.0
- Python >= 3.10
- Docker >= 24.0
- GitHub Actions runner (self-hosted for GovCloud)
- OPA >= 0.55.0

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 2- Fedramp-Compliance-Automation"

# Install Python dependencies
pip install -r requirements.txt

# Configure AWS GovCloud credentials
export AWS_PROFILE=govcloud
aws configure --profile govcloud
```

### 2. Initialize Compliance Baseline

```bash
# Initialize Terraform with GovCloud provider
cd terraform
terraform init -backend-config=environments/govcloud.tfvars

# Deploy compliance baseline infrastructure
terraform plan -var-file=environments/govcloud.tfvars
terraform apply -var-file=environments/govcloud.tfvars
```

### 3. Run Initial Compliance Scan

```bash
# Execute full compliance assessment
python compliance_engine/scan.py --framework fedramp-moderate --output reports/

# Generate SSP documentation
python ssp_generator/generate.py --baseline moderate --format docx

# Start continuous monitoring
python monitoring/continuous_monitor.py --daemon
```

## Project Structure

```
Project 2- Fedramp-Compliance-Automation/
|-- compliance_engine/
|   |-- controls/              # NIST 800-53 control definitions
|   |-- mappings/              # Control-to-resource mappings
|   |-- scan.py                # Main compliance scanner
|   |-- remediate.py           # Auto-remediation engine
|   |-- evidence_collector.py  # Audit evidence gathering
|-- ssp_generator/
|   |-- templates/             # SSP Jinja2 templates
|   |-- generate.py            # SSP document generator
|   |-- sections/              # SSP section builders
|-- terraform/
|   |-- modules/
|   |   |-- iam_baseline/      # IAM hardening module
|   |   |-- logging/           # CloudTrail & Config setup
|   |   |-- encryption/        # KMS & encryption at rest
|   |   |-- network/           # VPC & security groups
|   |-- environments/          # Environment-specific tfvars
|   |-- policies/              # OPA policy definitions
|-- monitoring/
|   |-- dashboards/            # Grafana dashboard configs
|   |-- continuous_monitor.py  # Real-time monitoring daemon
|   |-- alerting/              # Alert rule definitions
|-- poam/
|   |-- tracker.py             # POA&M management
|   |-- templates/             # POA&M document templates
|-- tests/
|   |-- unit/                  # Unit tests
|   |-- integration/           # Integration tests
|   |-- compliance/            # Compliance validation tests
|-- .github/
|   |-- workflows/             # CI/CD pipeline definitions
|-- requirements.txt
|-- docker-compose.yml
|-- README.md
```

## CI/CD Pipeline

The GitHub Actions workflow automates the full compliance lifecycle:

1. **PR Stage** - Terraform plan + OPA policy check + compliance pre-scan
2. **Merge Stage** - Terraform apply + evidence collection + SSP regeneration
3. **Scheduled** - Daily compliance scans + POA&M status updates + drift detection
4. **On-Demand** - Full audit package generation for 3PAO assessments

## Compliance Reporting

```bash
# Generate full audit package
python compliance_engine/audit_package.py --format fedramp --output audit/

# Export compliance metrics
python monitoring/export_metrics.py --period 30d --format csv

# Generate executive summary
python reports/executive_summary.py --quarter Q1-2026
```

## Cost Estimates

| Environment | Monthly Cost |
|-------------|-------------|
| Dev/Test | ~$150-300 |
| Staging | ~$500-800 |
| Production (GovCloud) | ~$2,000-5,000 |

## License

MIT License
