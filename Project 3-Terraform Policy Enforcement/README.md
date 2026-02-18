# Terraform Policy Enforcement

**A comprehensive policy-as-code framework that enforces security, cost, and operational guardrails across Terraform deployments using OPA, Sentinel, and custom policy engines with automated PR gating.**

## Architecture Overview

This project provides a multi-layered policy enforcement system for Terraform infrastructure deployments. It integrates with CI/CD pipelines to validate Terraform plans against organizational policies before any infrastructure changes reach production, ensuring compliance with security standards, cost budgets, and architectural best practices.

### Core Components

- **Policy Engine** - Evaluates Terraform plans against Rego/Sentinel policies with severity-based enforcement
- **Cost Guardian** - Pre-deployment cost estimation and budget threshold enforcement using Infracost
- **Security Scanner** - Static analysis of Terraform configurations using tfsec, Checkov, and custom rules
- **Drift Detector** - Identifies configuration drift between Terraform state and live infrastructure
- **PR Gate** - GitHub Actions integration that blocks non-compliant infrastructure changes
- **Policy Library** - 200+ pre-built policies covering AWS, Azure, and GCP best practices
- **Exception Manager** - Workflow for temporary policy exemptions with auto-expiry and audit trail

### Technology Stack

| Component | Technology |
|-----------|------------|
| Policy Languages | Rego (OPA), Sentinel, Python |
| IaC Framework | Terraform >= 1.5, OpenTofu |
| Static Analysis | tfsec, Checkov, TFLint |
| Cost Analysis | Infracost |
| CI/CD | GitHub Actions, GitLab CI |
| State Backend | S3 + DynamoDB (locking) |
| Notification | Slack, PagerDuty, SNS |
| Dashboard | Grafana, custom React UI |
| Testing | pytest, Conftest, Terratest |

## Policy Categories

| Category | Policies | Severity Levels | Auto-Remediation |
|----------|----------|----------------|------------------|
| Security | 85 rules | Critical, High, Medium | Yes (select) |
| Cost Management | 25 rules | High, Medium, Low | No (advisory) |
| Naming Conventions | 15 rules | Medium, Low | Yes |
| Tagging Standards | 20 rules | High, Medium | Yes |
| Network Security | 30 rules | Critical, High | Yes (select) |
| Encryption | 15 rules | Critical, High | Yes |
| IAM Best Practices | 20 rules | Critical, High | No (manual) |

## Prerequisites

- Terraform >= 1.5.0 or OpenTofu >= 1.6.0
- Python >= 3.10
- OPA >= 0.55.0
- Infracost API key
- GitHub repository with Actions enabled
- AWS credentials for target environments

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 3-Terraform Policy Enforcement"

# Install dependencies
pip install -r requirements.txt
brew install opa tfsec infracost tflint

# Configure Infracost
infracost auth login
```

### 2. Initialize Policy Engine

```bash
# Load policy library
python policy_engine/init.py --load-defaults

# Validate policy syntax
opa check policies/rego/ --strict

# Run policy tests
conftest verify --policy policies/rego/
```

### 3. Evaluate a Terraform Plan

```bash
# Generate Terraform plan JSON
cd example-infrastructure
terraform init
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Run policy evaluation
python policy_engine/evaluate.py --plan tfplan.json --policy-set default

# Run cost analysis
infracost breakdown --path . --format json | python cost_guardian/evaluate.py
```

## Project Structure

```
Project 3-Terraform Policy Enforcement/
|-- policy_engine/
|   |-- evaluate.py              # Main policy evaluation engine
|   |-- init.py                  # Policy library initialization
|   |-- exceptions.py            # Exception/exemption manager
|   |-- reporter.py              # Policy evaluation reporting
|-- policies/
|   |-- rego/                    # OPA Rego policy definitions
|   |   |-- security/            # Security policies
|   |   |-- cost/                # Cost management policies
|   |   |-- naming/              # Naming convention policies
|   |   |-- tagging/             # Tagging standard policies
|   |   |-- network/             # Network security policies
|   |-- sentinel/                # Sentinel policy definitions
|   |-- custom/                  # Custom Python policy checks
|-- cost_guardian/
|   |-- evaluate.py              # Cost policy evaluator
|   |-- budgets.yml              # Budget threshold configs
|   |-- alerts.py                # Cost alert manager
|-- security_scanner/
|   |-- scanner.py               # Unified security scanner
|   |-- custom_rules/            # Custom tfsec/Checkov rules
|-- example-infrastructure/
|   |-- compliant/               # Example compliant configs
|   |-- non-compliant/           # Example violations for testing
|-- tests/
|   |-- unit/                    # Unit tests
|   |-- integration/             # Integration tests
|   |-- policy/                  # Policy logic tests
|-- .github/
|   |-- workflows/
|   |   |-- policy-check.yml     # PR policy gate workflow
|   |   |-- drift-detect.yml     # Scheduled drift detection
|-- requirements.txt
|-- README.md
```

## CI/CD Integration

The policy enforcement pipeline runs automatically on every PR:

1. **Plan Generation** - Terraform plan created in isolated workspace
2. **Policy Evaluation** - All applicable policies evaluated against plan
3. **Cost Analysis** - Infracost estimates compared against budget thresholds
4. **Security Scan** - tfsec + Checkov + custom rules execution
5. **Gate Decision** - PR blocked if critical/high violations found
6. **Report** - Detailed compliance report posted as PR comment

## Writing Custom Policies

```rego
# Example: Deny public S3 buckets
package terraform.s3

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.after.acl == "public-read"
    msg := sprintf("S3 bucket '%s' cannot have public-read ACL", [resource.name])
}
```

## Cost Estimates

| Environment | Monthly Cost |
|-------------|-------------|
| Policy Engine Only | ~$0 (runs in CI) |
| With Dashboard | ~$50-100 |
| Enterprise (multi-org) | ~$200-500 |

## License

MIT License
