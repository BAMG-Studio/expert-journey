# Multi-Account AWS Governance

**A comprehensive AWS Organizations multi-account governance framework that automates account provisioning, enforces security baselines, manages cross-account access, and provides centralized compliance monitoring across hundreds of AWS accounts using Control Tower, SCPs, and custom guardrails.**

## Architecture Overview

This project implements a scalable multi-account AWS governance strategy using the landing zone pattern. It automates the entire account lifecycle from provisioning through decommissioning, enforces organizational policies via Service Control Policies (SCPs), deploys security baselines automatically, and provides centralized visibility across all accounts through a unified governance dashboard.

### Core Components

- **Account Factory** - Automated AWS account provisioning with pre-configured security baselines using Control Tower Account Factory for Terraform (AFT)
- **SCP Engine** - Hierarchical Service Control Policy management with version control and testing framework
- **Security Baseline** - Automated deployment of security controls (GuardDuty, SecurityHub, Config, CloudTrail) across all accounts
- **Cross-Account Access Manager** - Centralized IAM role management with just-in-time access and session recording
- **Budget Controller** - Organization-wide budget enforcement with per-account spending limits and alerts
- **Compliance Aggregator** - Centralized AWS Config aggregation with custom conformance packs
- **Network Hub** - Transit Gateway-based network architecture with centralized egress and inspection

### Technology Stack

| Component | Technology |
|-----------|------------|
| Landing Zone | AWS Control Tower, AFT |
| Policy Enforcement | Service Control Policies, Permission Boundaries |
| Account Provisioning | Account Factory for Terraform (AFT) |
| Security Services | GuardDuty, SecurityHub, Config, CloudTrail, Macie |
| Network | Transit Gateway, Network Firewall, Route 53 |
| Identity | AWS IAM Identity Center (SSO), IAM |
| Compliance | AWS Config, Conformance Packs, Custom Rules |
| Cost Management | AWS Organizations Billing, Budgets, Cost Explorer |
| IaC | Terraform, CloudFormation StackSets |
| CI/CD | GitHub Actions, CodePipeline |
| Monitoring | CloudWatch, Grafana, custom dashboards |

## Organization Structure

```
Root
|-- Management Account (billing, organizations)
|-- Security OU
|   |-- Log Archive Account (centralized logging)
|   |-- Audit Account (security tooling)
|   |-- Security Tooling Account (GuardDuty admin, SecurityHub)
|-- Infrastructure OU
|   |-- Network Hub Account (Transit Gateway, DNS)
|   |-- Shared Services Account (CI/CD, artifact repos)
|-- Workload OU
|   |-- Production OU
|   |   |-- Prod Account 1..N
|   |-- Staging OU
|   |   |-- Staging Account 1..N
|   |-- Development OU
|       |-- Dev Account 1..N
|-- Sandbox OU
|   |-- Sandbox Account 1..N (time-limited, auto-cleanup)
|-- Suspended OU
    |-- Decommissioned accounts (locked, pending deletion)
```

## SCP Policy Matrix

| Policy | Target OU | Effect | Enforcement |
|--------|----------|--------|-------------|
| Deny Region Restriction | Root | Deny non-approved regions | Mandatory |
| Deny Root User Actions | Root | Block root user API calls | Mandatory |
| Deny Public S3 | Workload OU | Prevent public S3 buckets | Mandatory |
| Deny IAM User Creation | Workload OU | Force SSO/role usage | Mandatory |
| Require Encryption | Production OU | Enforce encryption at rest | Mandatory |
| Deny VPC Changes | Production OU | Protect network config | Mandatory |
| Budget Limit Sandbox | Sandbox OU | Cap spending at $500/mo | Mandatory |
| Allow Full Access | Sandbox OU | Permissive for experimentation | Selective |

## Prerequisites

- AWS Organizations with Control Tower enabled
- Management account with OrganizationAdmin access
- Terraform >= 1.5.0
- Python >= 3.10
- AWS CLI v2 configured with SSO profiles
- GitHub repository with Actions enabled

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 10- Multi Account AWS Governance"

# Install dependencies
pip install -r requirements.txt

# Configure management account access
aws configure sso --profile management
aws sso login --profile management
```

### 2. Deploy Governance Baseline

```bash
# Initialize Account Factory for Terraform
cd aft
terraform init
terraform apply -var-file=org-config.tfvars

# Deploy SCPs
python scp_engine/deploy.py --config policies/scp-manifest.yml

# Deploy security baselines to all accounts
python baselines/deploy_all.py --target-ou Workload --baseline standard
```

### 3. Provision a New Account

```bash
# Request new account via Account Factory
python account_factory/provision.py \
  --name "proj-alpha-prod" \
  --email proj-alpha-prod@company.com \
  --ou Production \
  --baseline standard \
  --budget 5000

# Verify account baseline
python baselines/verify.py --account proj-alpha-prod
```

## Project Structure

```
Project 10- Multi Account AWS Governance/
|-- aft/
|   |-- main.tf                    # AFT Terraform configuration
|   |-- account-request/           # Account request definitions
|   |-- account-customizations/    # Per-account customizations
|   |-- global-customizations/     # Organization-wide customizations
|   |-- org-config.tfvars          # Organization configuration
|-- scp_engine/
|   |-- deploy.py                  # SCP deployment manager
|   |-- test.py                    # SCP testing framework
|   |-- policies/
|   |   |-- security/              # Security SCPs
|   |   |-- cost/                  # Cost control SCPs
|   |   |-- network/               # Network restriction SCPs
|   |   |-- scp-manifest.yml       # SCP deployment manifest
|-- baselines/
|   |-- standard/                  # Standard security baseline
|   |-- enhanced/                  # Enhanced security baseline
|   |-- deploy_all.py              # Baseline deployment orchestrator
|   |-- verify.py                  # Baseline verification
|   |-- stacksets/                 # CloudFormation StackSets
|-- account_factory/
|   |-- provision.py               # Account provisioning
|   |-- decommission.py            # Account decommissioning
|   |-- lifecycle.py               # Account lifecycle manager
|-- access_manager/
|   |-- sso_config/                # IAM Identity Center configs
|   |-- permission_sets/           # SSO permission set definitions
|   |-- jit_access.py              # Just-in-time access manager
|-- budget_controller/
|   |-- budgets.py                 # Budget management
|   |-- alerts.py                  # Cost alert configuration
|   |-- reports.py                 # Cost reporting
|-- compliance/
|   |-- aggregator.py              # Config aggregator setup
|   |-- conformance_packs/         # Custom conformance packs
|   |-- custom_rules/              # Custom Config rules
|   |-- dashboard.py               # Compliance dashboard
|-- network/
|   |-- transit_gateway/           # TGW configuration
|   |-- dns/                       # Route 53 centralized DNS
|   |-- firewall/                  # Network Firewall rules
|-- tests/
|   |-- unit/                      # Unit tests
|   |-- integration/               # Integration tests
|   |-- scp_tests/                 # SCP policy tests
|-- .github/
|   |-- workflows/                 # CI/CD pipeline definitions
|-- requirements.txt
|-- README.md
```

## Account Lifecycle

1. **Request** - Account request submitted via IaC or self-service portal
2. **Provision** - AFT creates account with Control Tower enrollment
3. **Baseline** - Security baseline deployed (GuardDuty, Config, CloudTrail)
4. **Configure** - Network connectivity, SSO access, budget alerts
5. **Validate** - Compliance check confirms all controls active
6. **Operate** - Account available for workload deployment
7. **Monitor** - Continuous compliance monitoring and cost tracking
8. **Decommission** - Move to Suspended OU, cleanup resources, lock account

## Cost Estimates

| Scale | Monthly Cost |
|-------|-------------|
| 5-10 Accounts | ~$200-500 |
| 25-50 Accounts | ~$500-2,000 |
| 100+ Accounts | ~$2,000-8,000 |

## License

MIT License
