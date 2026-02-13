# Multi-Account AWS Governance

## Overview

> **Mentor Note**: Imagine running a company where every department has its own bank account, but you need central oversight of spending, compliance, and security. Multi-account AWS governance is exactly that - managing dozens or hundreds of AWS accounts from a central control plane.

This project implements a comprehensive governance framework for organizations running workloads across multiple AWS accounts. It uses AWS Organizations, Service Control Policies (SCPs), and custom automation to enforce security baselines, manage costs, and maintain compliance across the entire AWS estate.

### Why This Matters

Organizations adopt multi-account strategies to:
- **Isolate workloads** - A security breach in dev does not affect production
- **Manage billing** - Track costs per team, project, or environment
- **Enforce compliance** - Apply different regulatory controls per account
- **Limit blast radius** - Resource limits and permissions stay contained

---

## Architecture

```
+--------------------------------------------------+
|              AWS Organizations Root               |
|  +--------------------------------------------+  |
|  |         Management Account                 |  |
|  |  - SCPs, CloudTrail, Config Rules          |  |
|  +--------------------------------------------+  |
|       |              |              |              |
|  +----------+  +----------+  +----------+         |
|  |  Security |  |   Prod   |  |   Dev    |         |
|  |    OU     |  |    OU    |  |    OU    |         |
|  +----------+  +----------+  +----------+         |
|   |       |     |       |     |       |            |
|  Log   Audit  Prod-A  Prod-B Dev-A  Sandbox       |
+--------------------------------------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Organization Management | AWS Organizations | Account hierarchy and SCPs |
| Account Factory | AWS Control Tower + AFT | Automated account provisioning |
| Policy Enforcement | Service Control Policies | Preventive guardrails |
| Config Monitoring | AWS Config + Rules | Detective controls |
| Centralized Logging | CloudTrail + S3 | Audit trail across all accounts |
| Cost Management | AWS Budgets + CUR | Financial governance |

---

## Core Concepts

### Organizational Units (OUs)

OUs are logical groupings within AWS Organizations:

```
Root
  +-- Security OU
  |     +-- Log Archive Account
  |     +-- Audit Account
  +-- Infrastructure OU
  |     +-- Shared Services Account
  |     +-- Network Hub Account
  +-- Workloads OU
  |     +-- Production OU
  |     +-- Development OU
  +-- Sandbox OU
        +-- Individual sandbox accounts
```

### Service Control Policies (SCPs)

SCPs set permission boundaries for entire OUs:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyDisablingCloudTrail",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyLeavingOrganization",
      "Effect": "Deny",
      "Action": "organizations:LeaveOrganization",
      "Resource": "*"
    }
  ]
}
```

> **Key Insight**: SCPs are deny-only guardrails. They do not grant permissions; they restrict what IAM policies can allow.

---

## Implementation Guide

### Step 1: Account Factory with Terraform

```hcl
module "account_factory" {
  source = "./modules/account-factory"
  
  accounts = {
    "prod-workload-a" = {
      email    = "aws+prod-a@company.com"
      ou_name  = "Production"
      tags     = { Environment = "production", CostCenter = "eng-001" }
    }
    "dev-workload-a" = {
      email    = "aws+dev-a@company.com"
      ou_name  = "Development"
      tags     = { Environment = "development", CostCenter = "eng-002" }
    }
  }
}

resource "aws_organizations_account" "this" {
  for_each  = var.accounts
  name      = each.key
  email     = each.value.email
  parent_id = data.aws_organizations_organizational_unit.this[each.value.ou_name].id
  tags      = each.value.tags
  
  lifecycle {
    prevent_destroy = true
  }
}
```

### Step 2: Centralized CloudTrail

```hcl
resource "aws_cloudtrail" "org_trail" {
  name                       = "org-management-trail"
  s3_bucket_name            = aws_s3_bucket.cloudtrail_logs.id
  is_organization_trail     = true
  is_multi_region_trail     = true
  enable_log_file_validation = true
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
```

### Step 3: AWS Config Rules Across Accounts

```python
import boto3

def deploy_config_rules(account_ids, rules):
    """Deploy AWS Config rules to all member accounts."""
    for account_id in account_ids:
        session = assume_role(account_id, "ConfigDeploymentRole")
        config_client = session.client("config")
        
        for rule in rules:
            config_client.put_config_rule(
                ConfigRule={
                    "ConfigRuleName": rule["name"],
                    "Source": {
                        "Owner": "AWS",
                        "SourceIdentifier": rule["identifier"]
                    },
                    "Scope": rule.get("scope", {})
                }
            )
            print(f"Deployed {rule['name']} to {account_id}")
```

---

## Deployment

### Prerequisites

- AWS Organizations enabled with all features
- Management account with admin access
- Terraform 1.5+
- Python 3.11+ with boto3

### Quick Start

```bash
# Initialize Terraform
cd terraform/governance
terraform init

# Plan and apply organization structure
terraform plan -var-file=org.tfvars
terraform apply -var-file=org.tfvars

# Deploy Config rules via Python
python deploy_config_rules.py --config rules.yaml
```

---

## Testing Strategy

```bash
# Validate SCPs do not break legitimate operations
aws organizations list-policies --filter SERVICE_CONTROL_POLICY

# Test account creation workflow
python -m pytest tests/test_account_factory.py -v

# Verify Config rule compliance
aws configservice get-compliance-summary-by-config-rule
```

---

## Quick Reference

| Task | Command |
|------|--------|
| List all accounts | `aws organizations list-accounts` |
| List SCPs | `aws organizations list-policies --filter SERVICE_CONTROL_POLICY` |
| Check Config compliance | `aws configservice get-compliance-summary-by-resource-type` |
| View org structure | `aws organizations list-organizational-units-for-parent --parent-id <root-id>` |

### Links
- [AWS Organizations Documentation](https://docs.aws.amazon.com/organizations/)
- [AWS Control Tower](https://docs.aws.amazon.com/controltower/)
- [SCP Best Practices](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
