# DevSecOps & Cloud Security Portfolio

> **BAMG Studio** | Generated 2026-02-13
>
> Comprehensive documentation for 12 enterprise-grade security,
> DevOps, and ML engineering projects demonstrating expertise in
> AWS cloud architecture, security automation, and MLOps.

---

## Table of Contents

1. [Multi Account Aws Governance](#01-multi-account-aws-governance)
2. [Terraform Policy Enforcement](#02-terraform-policy-enforcement)
3. [Fedramp Compliance Automation](#03-fedramp-compliance-automation)
4. [Infrastructure Drift Detection](#04-infrastructure-drift-detection)
5. [Incident Response Orchestration](#05-incident-response-orchestration)
6. [Siem Opensearch Deployment](#06-siem-opensearch-deployment)
7. [Kubernetes Security Hardening](#07-kubernetes-security-hardening)
8. [Ai Security Sbom Pipeline](#08-ai-security-sbom-pipeline)
9. [Mlops Model Registry](#09-mlops-model-registry)
10. [Serverless Data Pipeline](#10-serverless-data-pipeline)
11. [Supply Chain Risk Api](#11-supply-chain-risk-api)
12. [Ai Threat Modeling Framework](#12-ai-threat-modeling-framework)

---



---

<!-- PROJECT: 01-multi-account-aws-governance -->

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



---

<!-- PROJECT: 02-terraform-policy-enforcement -->

# Terraform Policy Enforcement

## Overview

> **Mentor Note**: Imagine a building inspector who checks blueprints before construction begins. Terraform policy enforcement does the same for cloud infrastructure - it validates your infrastructure-as-code against security and compliance rules before any resources are created.

This project implements a policy-as-code framework that validates Terraform configurations against organizational security standards, compliance requirements, and cost controls. Using Open Policy Agent (OPA) with Rego policies and Sentinel, it creates automated guardrails that prevent misconfigurations from reaching production.

### Why This Matters

Infrastructure misconfigurations are the leading cause of cloud security breaches. Policy enforcement shifts security left by catching issues during the planning phase rather than after deployment. Key benefits include:

- Preventing public S3 buckets, open security groups, and unencrypted resources
- Enforcing tagging standards for cost allocation
- Ensuring compliance with frameworks like CIS Benchmarks and SOC 2
- Reducing manual security review bottlenecks

---

## Architecture

```
+------------------+     +----------------+     +------------------+
|   Developer      |---->|  Git Push /    |---->|  CI Pipeline     |
|   Workstation    |     |  Pull Request  |     |  (GitHub Actions)|
+------------------+     +----------------+     +------------------+
                                                         |
                                                         v
+------------------+     +----------------+     +------------------+
|  Policy          |<----|  OPA / Rego    |<----|  terraform plan  |
|  Results         |     |  Evaluation    |     |  (JSON output)   |
+------------------+     +----------------+     +------------------+
         |
         v
+------------------+
|  Approve / Block |
|  Deployment      |
+------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Policy Engine | OPA + Rego | Evaluate Terraform plans against rules |
| CI Integration | GitHub Actions | Automated policy checks on PRs |
| Plan Analysis | terraform plan -json | Structured plan output for evaluation |
| Policy Library | Custom Rego policies | Organizational security standards |
| Reporting | PR comments + dashboards | Visibility into policy violations |

---

## Core Concepts

### What is Policy-as-Code?

Policy-as-code means writing compliance and security rules in a programming language that can be version-controlled, tested, and automatically enforced:

```rego
# policy/s3_encryption.rego
package terraform.s3

deny[msg] {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "aws_s3_bucket"
    not has_encryption(resource)
    msg := sprintf("S3 bucket '%s' must have server-side encryption enabled", [resource.name])
}

has_encryption(resource) {
    resource.values.server_side_encryption_configuration[_]
}
```

### OPA vs Sentinel

| Feature | OPA (Open Policy Agent) | Sentinel (HashiCorp) |
|---------|------------------------|---------------------|
| License | Open Source (Apache 2.0) | Commercial (Terraform Cloud) |
| Language | Rego | Sentinel Language |
| Integration | Any CI/CD pipeline | Terraform Cloud/Enterprise |
| Ecosystem | CNCF graduated project | HashiCorp only |
| Best For | Multi-tool policy enforcement | Deep Terraform integration |

---

## Implementation Guide

### Step 1: Policy Library Structure

```
policies/
  terraform/
    aws/
      s3/
        encryption.rego
        public_access.rego
      ec2/
        instance_types.rego
        public_ip.rego
      iam/
        wildcard_actions.rego
    common/
      tagging.rego
      naming.rego
  tests/
    s3_test.rego
    ec2_test.rego
```

### Step 2: Core Security Policies

```rego
# policy/aws/security_group.rego
package terraform.aws.security_group

deny[msg] {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "aws_security_group_rule"
    resource.values.type == "ingress"
    resource.values.cidr_blocks[_] == "0.0.0.0/0"
    resource.values.from_port <= 22
    resource.values.to_port >= 22
    msg := sprintf("Security group '%s' allows SSH from 0.0.0.0/0", [resource.name])
}

# policy/aws/encryption.rego
package terraform.aws.encryption

deny[msg] {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "aws_ebs_volume"
    not resource.values.encrypted
    msg := sprintf("EBS volume '%s' must be encrypted", [resource.name])
}
```

### Step 3: CI/CD Integration

```yaml
# .github/workflows/terraform-policy.yml
name: Terraform Policy Check
on:
  pull_request:
    paths: ["terraform/**"]

jobs:
  policy-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: hashicorp/setup-terraform@v3
      
      - name: Terraform Plan
        run: |
          cd terraform/
          terraform init
          terraform plan -out=tfplan
          terraform show -json tfplan > plan.json
      
      - name: Install OPA
        run: |
          curl -L https://openpolicyagent.org/downloads/latest/opa_linux_amd64 -o opa
          chmod +x opa
      
      - name: Evaluate Policies
        run: |
          ./opa eval \
            --data policies/ \
            --input terraform/plan.json \
            "data.terraform" \
            --format pretty
```

### Step 4: Tagging Enforcement

```rego
package terraform.common.tagging

required_tags := {"Environment", "CostCenter", "Owner", "Project"}

deny[msg] {
    resource := input.planned_values.root_module.resources[_]
    tags := object.get(resource.values, "tags", {})
    missing := required_tags - {key | tags[key]}
    count(missing) > 0
    msg := sprintf("Resource '%s' is missing required tags: %v", [resource.address, missing])
}
```

---

## Deployment

### Prerequisites

- Terraform 1.5+
- OPA CLI
- GitHub repository with Actions enabled

### Quick Start

```bash
# Install OPA
brew install opa

# Run policy tests
opa test policies/ -v

# Evaluate against a Terraform plan
terraform plan -out=tfplan && terraform show -json tfplan > plan.json
opa eval --data policies/ --input plan.json "data.terraform"
```

---

## Testing Strategy

```rego
# policies/tests/s3_test.rego
package terraform.s3_test

import data.terraform.s3

test_deny_unencrypted_bucket {
    result := s3.deny with input as {
        "planned_values": {
            "root_module": {
                "resources": [{
                    "type": "aws_s3_bucket",
                    "name": "test_bucket",
                    "values": {}
                }]
            }
        }
    }
    count(result) > 0
}
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Run policy tests | `opa test policies/ -v` |
| Evaluate plan | `opa eval --data policies/ --input plan.json "data.terraform"` |
| Format Rego files | `opa fmt -w policies/` |
| Check Rego syntax | `opa check policies/` |

### Links
- [Open Policy Agent](https://www.openpolicyagent.org/)
- [Rego Language Reference](https://www.openpolicyagent.org/docs/latest/policy-language/)
- [Terraform JSON Output](https://developer.hashicorp.com/terraform/internals/json-format)



---

<!-- PROJECT: 03-fedramp-compliance-automation -->

# FedRAMP Compliance Automation

## Overview

> **Mentor Note**: FedRAMP is like a standardized safety inspection for cloud services used by the US government. Just as restaurants need health inspections to serve food, cloud providers need FedRAMP authorization to serve federal agencies. This project automates the continuous monitoring and evidence collection required to maintain that authorization.

This project automates FedRAMP compliance monitoring, evidence collection, and reporting for cloud environments. It maps AWS services to NIST 800-53 controls, continuously monitors compliance posture, and generates audit-ready documentation for FedRAMP authorization assessments.

### Why This Matters

FedRAMP authorization requires demonstrating compliance with hundreds of security controls. Manual compliance tracking is unsustainable because:

- FedRAMP Moderate requires 325+ controls
- Continuous monitoring demands monthly, quarterly, and annual evidence
- Manual evidence collection takes weeks of engineering time
- Configuration drift can silently break compliance

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  AWS Config      |---->|  Compliance      |---->|  Evidence        |
|  Rules           |     |  Engine          |     |  Repository (S3) |
+------------------+     +------------------+     +------------------+
         |                        |                        |
         v                        v                        v
+------------------+     +------------------+     +------------------+
|  SecurityHub     |     |  Control Mapping |     |  Report          |
|  Findings        |     |  (NIST 800-53)   |     |  Generator       |
+------------------+     +------------------+     +------------------+
                                  |                        |
                                  v                        v
                          +------------------+     +------------------+
                          |  OSCAL Output    |     |  POA&M Tracker   |
                          |  (JSON/XML)      |     |  Dashboard       |
                          +------------------+     +------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Config Rules | AWS Config | Continuous compliance checks |
| SecurityHub | AWS SecurityHub | Centralized findings aggregation |
| Control Mapping | Python + OSCAL | Map AWS controls to NIST 800-53 |
| Evidence Collection | Lambda + S3 | Automated evidence gathering |
| Reporting | Python + Jinja2 | Generate SSP and POA&M documents |
| Dashboard | CloudWatch | Real-time compliance visibility |

---

## Core Concepts

### NIST 800-53 Control Families

| Family | Code | Example Controls |
|--------|------|------------------|
| Access Control | AC | AC-2 Account Management, AC-6 Least Privilege |
| Audit | AU | AU-2 Event Logging, AU-6 Audit Review |
| Configuration Mgmt | CM | CM-2 Baseline Config, CM-6 Config Settings |
| Identification | IA | IA-2 Multi-Factor Auth, IA-5 Authenticator Mgmt |
| System Protection | SC | SC-7 Boundary Protection, SC-28 Data at Rest |

### FedRAMP Impact Levels

| Level | Controls | Data Sensitivity |
|-------|----------|------------------|
| **Low** | ~125 controls | Public, non-sensitive |
| **Moderate** | ~325 controls | Controlled unclassified (CUI) |
| **High** | ~421 controls | Critical systems, law enforcement |

---

## Implementation Guide

### Step 1: AWS Config Rules for NIST Controls

```python
NIST_CONFIG_MAPPING = {
    "AC-2": [
        {"rule": "iam-user-mfa-enabled", "description": "All IAM users must have MFA"},
        {"rule": "iam-no-inline-policy-check", "description": "No inline IAM policies"}
    ],
    "AC-6": [
        {"rule": "iam-policy-no-statements-with-admin-access", "description": "No admin access policies"},
        {"rule": "iam-root-access-key-check", "description": "No root access keys"}
    ],
    "SC-28": [
        {"rule": "s3-default-encryption-kms", "description": "S3 KMS encryption"},
        {"rule": "encrypted-volumes", "description": "EBS volumes encrypted"},
        {"rule": "rds-storage-encrypted", "description": "RDS storage encrypted"}
    ]
}
```

### Step 2: Evidence Collection Lambda

```python
import boto3
import json
from datetime import datetime

def collect_evidence(event, context):
    """Automated evidence collection for FedRAMP controls."""
    s3 = boto3.client("s3")
    config = boto3.client("config")
    
    timestamp = datetime.utcnow().strftime("%Y-%m-%d")
    
    for control_id, rules in NIST_CONFIG_MAPPING.items():
        evidence = {
            "control_id": control_id,
            "collection_date": timestamp,
            "results": []
        }
        
        for rule in rules:
            compliance = config.get_compliance_details_by_config_rule(
                ConfigRuleName=rule["rule"]
            )
            evidence["results"].append({
                "rule": rule["rule"],
                "compliant_resources": count_compliant(compliance),
                "non_compliant_resources": count_non_compliant(compliance)
            })
        
        s3.put_object(
            Bucket="fedramp-evidence",
            Key=f"{timestamp}/{control_id}/evidence.json",
            Body=json.dumps(evidence, indent=2)
        )
```

### Step 3: OSCAL-Formatted Output

```python
def generate_oscal_assessment(controls_status):
    """Generate NIST OSCAL-formatted assessment results."""
    oscal = {
        "assessment-results": {
            "uuid": str(uuid.uuid4()),
            "metadata": {
                "title": "FedRAMP Continuous Monitoring Assessment",
                "last-modified": datetime.utcnow().isoformat()
            },
            "results": []
        }
    }
    
    for control_id, status in controls_status.items():
        oscal["assessment-results"]["results"].append({
            "uuid": str(uuid.uuid4()),
            "title": f"Assessment of {control_id}",
            "findings": [{
                "target": {"type": "control", "target-id": control_id},
                "status": {"state": "satisfied" if status["compliant"] else "not-satisfied"}
            }]
        })
    
    return oscal
```

---

## Deployment

### Prerequisites

- AWS Account with Config, SecurityHub, Lambda
- Python 3.11+
- Understanding of NIST 800-53 Rev 5

### Quick Start

```bash
# Deploy Config rules
cd terraform/fedramp
terraform apply

# Run initial evidence collection
python collect_evidence.py --baseline moderate

# Generate compliance report
python generate_report.py --format oscal --output report.json
```

---

## Testing Strategy

```bash
# Validate OSCAL output format
python -m oscal_validator report.json

# Test evidence collection with mock data
python -m pytest tests/test_evidence.py -v

# Verify control mapping completeness
python verify_mappings.py --baseline moderate
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Check compliance status | `aws configservice get-compliance-summary-by-config-rule` |
| List SecurityHub findings | `aws securityhub get-findings --filters ...` |
| Export evidence | `python collect_evidence.py --control AC-2` |
| Generate POA&M | `python generate_poam.py --format xlsx` |

### Links
- [FedRAMP Official](https://www.fedramp.gov/)
- [NIST 800-53 Rev 5](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [OSCAL](https://pages.nist.gov/OSCAL/)



---

<!-- PROJECT: 04-infrastructure-drift-detection -->

# Infrastructure Drift Detection

## Overview

> **Mentor Note**: Imagine building a house from blueprints, but over time someone adds a window here, moves a wall there - without updating the plans. Infrastructure drift is the same problem in cloud computing: your actual infrastructure no longer matches your Terraform code. This project detects and alerts on those differences.

This project implements continuous drift detection for Terraform-managed infrastructure. It compares the desired state defined in code with the actual state of cloud resources, identifies unauthorized changes, and triggers automated remediation workflows.

### Why This Matters

- **Security risk**: Manual changes may introduce misconfigurations
- **Compliance gaps**: Drift can violate regulatory requirements
- **Operational chaos**: Teams lose trust in infrastructure-as-code
- **Incident response**: Unknown changes complicate troubleshooting

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  Terraform State |---->|  Drift Detection |---->|  Alert Engine    |
|  (S3 Backend)    |     |  Engine (Lambda) |     |  (SNS + Slack)   |
+------------------+     +------------------+     +------------------+
                                  |                        |
                                  v                        v
+------------------+     +------------------+     +------------------+
|  AWS CloudTrail  |     |  Drift Report    |     |  Auto-Remediate  |
|  (Change Source)  |     |  (DynamoDB)      |     |  (Step Functions)|
+------------------+     +------------------+     +------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Drift Scanner | Lambda + terraform plan | Detect state differences |
| Change Tracker | CloudTrail + EventBridge | Identify who made changes |
| Alert System | SNS + Slack webhook | Notify teams of drift |
| Drift Database | DynamoDB | Track drift history and trends |
| Remediation | Step Functions | Automated or approval-based fixes |
| Scheduler | EventBridge Rules | Run drift checks on schedule |

---

## Core Concepts

### Types of Infrastructure Drift

| Type | Description | Example |
|------|-----------|----------|
| **Configuration Drift** | Resource properties changed | Security group rule modified via console |
| **Resource Drift** | Resources added or deleted outside IaC | EC2 instance launched manually |
| **State Drift** | State file out of sync | Failed apply left partial state |
| **Dependency Drift** | External dependencies changed | AMI deprecated, cert expired |

### Detection Methods

1. **Terraform Plan Comparison**: Run `terraform plan` and parse the diff
2. **AWS Config Recording**: Track all resource configuration changes
3. **CloudTrail Analysis**: Identify console/CLI changes outside CI/CD
4. **State File Diffing**: Compare state snapshots over time

---

## Implementation Guide

### Step 1: Drift Detection Lambda

```python
import subprocess
import json
import boto3

def detect_drift(event, context):
    """Run terraform plan and detect drift."""
    result = subprocess.run(
        ["terraform", "plan", "-detailed-exitcode", "-json", "-no-color"],
        capture_output=True, text=True, cwd="/tmp/terraform"
    )
    
    # Exit code 2 means changes detected (drift)
    if result.returncode == 2:
        plan_output = json.loads(result.stdout)
        drift_resources = extract_drifted_resources(plan_output)
        
        notify_drift(drift_resources)
        store_drift_record(drift_resources)
        
        return {"drift_detected": True, "resources": len(drift_resources)}
    
    return {"drift_detected": False}

def extract_drifted_resources(plan):
    drifted = []
    for change in plan.get("resource_changes", []):
        if change["change"]["actions"] != ["no-op"]:
            drifted.append({
                "address": change["address"],
                "type": change["type"],
                "actions": change["change"]["actions"]
            })
    return drifted
```

### Step 2: CloudTrail Change Correlation

```python
def correlate_changes(drifted_resource, timeframe_hours=24):
    """Find who made the change via CloudTrail."""
    client = boto3.client("cloudtrail")
    
    events = client.lookup_events(
        LookupAttributes=[{
            "AttributeKey": "ResourceName",
            "AttributeValue": drifted_resource["id"]
        }],
        StartTime=datetime.utcnow() - timedelta(hours=timeframe_hours)
    )
    
    return [{
        "user": e["Username"],
        "action": e["EventName"],
        "time": e["EventTime"].isoformat(),
        "source_ip": e.get("SourceIPAddress")
    } for e in events.get("Events", [])]
```

### Step 3: Scheduled Drift Checks

```yaml
# .github/workflows/drift-check.yml
name: Scheduled Drift Detection
on:
  schedule:
    - cron: "0 */6 * * *"  # Every 6 hours

jobs:
  drift-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      
      - name: Check for Drift
        run: |
          terraform init
          terraform plan -detailed-exitcode -out=drift.tfplan
        continue-on-error: true
      
      - name: Report Drift
        if: steps.plan.outcome == "failure"
        run: python report_drift.py --plan drift.tfplan
```

---

## Deployment

### Prerequisites

- Terraform state stored in S3 with DynamoDB locking
- CloudTrail enabled across all regions
- Lambda execution role with read access to target resources

### Quick Start

```bash
# Deploy drift detection infrastructure
cd terraform/drift-detection
terraform apply

# Run manual drift check
python drift_scanner.py --workspace production

# View drift history
python drift_report.py --days 30
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Manual drift check | `terraform plan -detailed-exitcode` |
| View state | `terraform state list` |
| Import existing resource | `terraform import <address> <id>` |
| Refresh state | `terraform refresh` |

### Links
- [Terraform Drift Detection](https://developer.hashicorp.com/terraform/tutorials/state/resource-drift)
- [AWS Config](https://docs.aws.amazon.com/config/)
- [CloudTrail](https://docs.aws.amazon.com/cloudtrail/)



---

<!-- PROJECT: 05-incident-response-orchestration -->

# Incident Response Orchestration

## Overview

> **Mentor Note**: When a security incident occurs, every minute counts. Incident response orchestration is like having a pre-planned emergency response playbook that automatically kicks into action - isolating threats, collecting evidence, and notifying the right people - while humans focus on decision-making.

This project implements automated incident response workflows using AWS Step Functions and Lambda. It detects security events from GuardDuty, SecurityHub, and CloudWatch, then executes predefined playbooks for containment, evidence collection, and recovery.

### Why This Matters

- Mean time to detect (MTTD) for breaches averages 204 days
- Automated response reduces containment time from hours to minutes
- Consistent playbook execution eliminates human error under pressure
- Forensic evidence is preserved before it can be tampered with

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  GuardDuty       |---->|  EventBridge     |---->|  Step Functions  |
|  SecurityHub     |     |  Rules           |     |  Orchestrator    |
|  CloudWatch      |     |                  |     |  (Playbooks)     |
+------------------+     +------------------+     +------------------+
                                                         |
                                  +----------------------+
                                  |          |           |
                                  v          v           v
                          +----------+ +----------+ +----------+
                          | Isolate  | | Collect  | | Notify   |
                          | Resource | | Evidence | | Teams    |
                          +----------+ +----------+ +----------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Event Detection | GuardDuty + SecurityHub | Identify security events |
| Event Routing | EventBridge | Route events to correct playbook |
| Orchestration | Step Functions | Execute multi-step workflows |
| Actions | Lambda functions | Individual response actions |
| Evidence Store | S3 (immutable) | Forensic evidence preservation |
| Communication | SNS + PagerDuty | Alert and escalation |

---

## Core Concepts

### Incident Severity Levels

| Level | Description | Response Time | Example |
|-------|-----------|--------------|----------|
| **P1 - Critical** | Active data breach | Immediate | Exfiltration detected |
| **P2 - High** | Compromised resource | < 1 hour | Crypto mining on EC2 |
| **P3 - Medium** | Policy violation | < 4 hours | Public S3 bucket |
| **P4 - Low** | Informational | < 24 hours | Failed login attempts |

### NIST Incident Response Phases

1. **Preparation** - Playbooks, tools, training
2. **Detection & Analysis** - Identify and validate incidents
3. **Containment** - Stop the spread
4. **Eradication** - Remove the threat
5. **Recovery** - Restore normal operations
6. **Lessons Learned** - Post-incident review

---

## Implementation Guide

### Step 1: EventBridge Rules

```hcl
resource "aws_cloudwatch_event_rule" "guardduty_high" {
  name        = "guardduty-high-severity"
  description = "Trigger IR playbook for high severity GuardDuty findings"
  
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 7] }]
    }
  })
}

resource "aws_cloudwatch_event_target" "ir_playbook" {
  rule = aws_cloudwatch_event_rule.guardduty_high.name
  arn  = aws_sfn_state_machine.ir_orchestrator.arn
}
```

### Step 2: EC2 Isolation Lambda

```python
import boto3

def isolate_ec2_instance(event, context):
    """Isolate a compromised EC2 instance."""
    ec2 = boto3.client("ec2")
    instance_id = event["detail"]["resource"]["instanceDetails"]["instanceId"]
    
    # Create forensic security group (no inbound/outbound)
    sg = ec2.create_security_group(
        GroupName=f"forensic-isolation-{instance_id}",
        Description="Forensic isolation - no traffic allowed",
        VpcId=get_instance_vpc(instance_id)
    )
    
    # Replace all security groups with isolation group
    ec2.modify_instance_attribute(
        InstanceId=instance_id,
        Groups=[sg["GroupId"]]
    )
    
    # Tag instance as isolated
    ec2.create_tags(
        Resources=[instance_id],
        Tags=[{"Key": "IR-Status", "Value": "isolated"},
              {"Key": "IR-Timestamp", "Value": datetime.utcnow().isoformat()}]
    )
    
    # Create EBS snapshots for forensics
    volumes = get_instance_volumes(instance_id)
    snapshots = []
    for vol_id in volumes:
        snap = ec2.create_snapshot(
            VolumeId=vol_id,
            Description=f"IR forensic snapshot - {instance_id}"
        )
        snapshots.append(snap["SnapshotId"])
    
    return {"instance_id": instance_id, "isolated": True, "snapshots": snapshots}
```

### Step 3: Step Functions State Machine

```json
{
  "StartAt": "ClassifyIncident",
  "States": {
    "ClassifyIncident": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:ACCOUNT:function:classify-incident",
      "Next": "SeverityRouter"
    },
    "SeverityRouter": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.severity",
          "StringEquals": "CRITICAL",
          "Next": "CriticalPlaybook"
        },
        {
          "Variable": "$.severity",
          "StringEquals": "HIGH",
          "Next": "HighPlaybook"
        }
      ],
      "Default": "StandardPlaybook"
    },
    "CriticalPlaybook": {
      "Type": "Parallel",
      "Branches": [
        {"StartAt": "IsolateResource", "States": {"IsolateResource": {"Type": "Task", "Resource": "arn:aws:lambda:us-east-1:ACCOUNT:function:isolate-resource", "End": true}}},
        {"StartAt": "CollectEvidence", "States": {"CollectEvidence": {"Type": "Task", "Resource": "arn:aws:lambda:us-east-1:ACCOUNT:function:collect-evidence", "End": true}}},
        {"StartAt": "NotifyTeam", "States": {"NotifyTeam": {"Type": "Task", "Resource": "arn:aws:lambda:us-east-1:ACCOUNT:function:notify-pagerduty", "End": true}}}
      ],
      "Next": "CreateTicket"
    }
  }
}
```

---

## Deployment

### Prerequisites

- AWS GuardDuty enabled
- AWS SecurityHub enabled
- Step Functions, Lambda, EventBridge access
- PagerDuty or Slack for notifications

### Quick Start

```bash
# Deploy IR infrastructure
cd terraform/incident-response
terraform apply

# Test with simulated finding
python simulate_finding.py --type ec2-compromise --severity high

# View playbook executions
aws stepfunctions list-executions --state-machine-arn <ARN>
```

---

## Quick Reference

| Task | Command |
|------|--------|
| List GuardDuty findings | `aws guardduty list-findings --detector-id <id>` |
| Trigger test finding | `aws guardduty create-sample-findings --detector-id <id>` |
| View Step Functions execution | `aws stepfunctions describe-execution --execution-arn <arn>` |

### Links
- [AWS Incident Response Guide](https://docs.aws.amazon.com/whitepapers/latest/aws-security-incident-response-guide/)
- [NIST SP 800-61](https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final)
- [AWS GuardDuty](https://docs.aws.amazon.com/guardduty/)



---

<!-- PROJECT: 06-siem-opensearch-deployment -->

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



---

<!-- PROJECT: 07-kubernetes-security-hardening -->

# Kubernetes Security Hardening

## Overview

> **Mentor Note**: Kubernetes is like a city manager for containers - it decides where applications run, how they communicate, and how they scale. But just like a city needs police, fire codes, and building inspections, Kubernetes needs security hardening to prevent attacks, limit blast radius, and maintain compliance.

This project implements comprehensive security hardening for Amazon EKS clusters following CIS Kubernetes Benchmark, NSA/CISA guidelines, and Pod Security Standards. It covers network policies, RBAC configuration, secrets management, image scanning, and runtime security monitoring.

### Why This Matters

- Kubernetes misconfigurations are the top attack vector for container environments
- Default EKS settings are permissive for ease of use, not security
- Container breakout attacks can compromise entire clusters
- Regulatory frameworks increasingly require container security controls

---

## Architecture

```
+--------------------------------------------------+
|                  EKS Cluster                       |
|  +--------------------------------------------+  |
|  |  Control Plane (AWS Managed)                |  |
|  |  - API Server hardening                     |  |
|  |  - Audit logging enabled                    |  |
|  +--------------------------------------------+  |
|  |  Worker Nodes                               |  |
|  |  +----------+ +----------+ +----------+     |  |
|  |  |  Pod     | |  Pod     | |  Pod     |     |  |
|  |  | Security | | Network  | | Resource |     |  |
|  |  | Context  | | Policies | | Limits   |     |  |
|  |  +----------+ +----------+ +----------+     |  |
|  +--------------------------------------------+  |
|  |  Security Layer                             |  |
|  |  - Falco (Runtime Detection)                |  |
|  |  - OPA Gatekeeper (Admission Control)       |  |
|  |  - Trivy (Image Scanning)                   |  |
|  +--------------------------------------------+  |
+--------------------------------------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Admission Control | OPA Gatekeeper | Enforce policies at deploy time |
| Network Security | Calico Network Policies | Microsegmentation between pods |
| Runtime Security | Falco | Detect anomalous container behavior |
| Image Scanning | Trivy + ECR scanning | Prevent vulnerable images |
| Secrets | AWS Secrets Manager + CSI | Secure secret injection |
| RBAC | Kubernetes RBAC | Least privilege access control |

---

## Core Concepts

### Pod Security Standards

| Level | Description | Use Case |
|-------|-----------|----------|
| **Privileged** | Unrestricted | System-level infrastructure pods |
| **Baseline** | Minimally restrictive | Standard workloads |
| **Restricted** | Heavily restricted | Security-sensitive workloads |

### Defense in Depth Layers

1. **Image Security** - Scan images before deployment
2. **Admission Control** - Enforce policies at deploy time
3. **Network Policies** - Restrict pod-to-pod communication
4. **Runtime Security** - Detect anomalies during execution
5. **Audit Logging** - Record all API server activity

---

## Implementation Guide

### Step 1: OPA Gatekeeper Constraints

```yaml
# Require all pods to have resource limits
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sContainerLimits
metadata:
  name: container-must-have-limits
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    cpu: "2"
    memory: "4Gi"
---
# Block privileged containers
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sPSPPrivilegedContainer
metadata:
  name: deny-privileged-containers
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    excludedNamespaces: ["kube-system"]
```

### Step 2: Network Policies

```yaml
# Default deny all ingress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
# Allow only specific service communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api-server
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### Step 3: Falco Runtime Rules

```yaml
- rule: Terminal shell in container
  desc: Detect shell opened in a container
  condition: >
    spawned_process and container and
    proc.name in (bash, sh, zsh) and
    not proc.pname in (cron, supervisord)
  output: >
    Shell opened in container
    (user=%user.name container=%container.name
    image=%container.image.repository)
  priority: WARNING
  tags: [container, shell, mitre_execution]
```

---

## Deployment

### Prerequisites

- Amazon EKS cluster (1.28+)
- kubectl configured
- Helm 3.x

### Quick Start

```bash
# Install OPA Gatekeeper
helm install gatekeeper gatekeeper/gatekeeper -n gatekeeper-system --create-namespace

# Install Falco
helm install falco falcosecurity/falco -n falco --create-namespace

# Apply network policies
kubectl apply -f network-policies/

# Apply Gatekeeper constraints
kubectl apply -f constraints/
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Check pod security | `kubectl get psp` |
| List network policies | `kubectl get networkpolicy -A` |
| View Gatekeeper violations | `kubectl get constraints -A` |
| Falco alerts | `kubectl logs -n falco -l app=falco` |
| Audit logs | `kubectl logs -n kube-system kube-apiserver` |

### Links
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NSA/CISA Kubernetes Hardening](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/security/docs/)



---

<!-- PROJECT: 08-ai-security-sbom-pipeline -->

# AI Security SBOM Pipeline

## Overview

> **Mentor Note**: Think of a Software Bill of Materials (SBOM) like an ingredient list on food packaging. Just as you check ingredients for allergens, an SBOM lets you check your software for known security vulnerabilities. This project automates that entire process and adds AI-powered prioritization to focus on what matters most.

This project implements an automated pipeline that generates, analyzes, and monitors Software Bills of Materials (SBOMs) for containerized applications, enhanced with AI-powered vulnerability prioritization. It integrates with CI/CD workflows to ensure every deployment is scanned and cataloged.

### Why This Matters

Modern applications depend on hundreds of open-source libraries. A single vulnerable dependency can compromise entire organizations. AI-enhanced SBOM analysis goes beyond traditional scanning by:

- Predicting which vulnerabilities are most likely to be exploited
- Identifying unusual dependency patterns that suggest supply chain attacks
- Prioritizing remediation based on actual runtime exposure
- Correlating findings across your entire application portfolio

---

## Architecture

```
+------------------+     +----------------+     +------------------+
|   Source Code    |---->|  CI/CD Pipeline |---->|  SBOM Generator  |
|   Repository     |     |  (GitHub Actions)|    |  (Syft/Trivy)    |
+------------------+     +----------------+     +------------------+
                                                         |
                                                         v
+------------------+     +----------------+     +------------------+
|  AI Prioritizer  |<----|  Vulnerability  |<----|  SBOM Storage    |
|  (ML Model)      |     |  Enrichment    |     |  (S3/DynamoDB)   |
+------------------+     +----------------+     +------------------+
         |
         v
+------------------+
|  Alert/Report    |
|  Dashboard       |
+------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| SBOM Generator | Syft + Trivy | Produce CycloneDX/SPDX format SBOMs |
| Storage Layer | S3 + DynamoDB | Version and store SBOMs with metadata |
| Vulnerability Enrichment | OSV.dev + NVD API | Map components to known CVEs |
| AI Prioritizer | Python ML (scikit-learn) | Score and rank vulnerabilities |
| Policy Engine | Open Policy Agent | Enforce organizational standards |
| Dashboard | CloudWatch + SNS | Visualize and alert on findings |

---

## Core Concepts

### SBOM Formats

| Format | Maintained By | Best For |
|--------|--------------|----------|
| **CycloneDX** | OWASP | Security vulnerability workflows |
| **SPDX** | Linux Foundation | License compliance (ISO standard) |

### AI-Enhanced Prioritization Features

1. **Reachability Analysis** - Is the vulnerable function actually called in your code?
2. **Exploit Maturity** - Are there known exploits in the wild?
3. **Environmental Context** - Is this service internet-facing?
4. **Historical Patterns** - How quickly do similar CVEs get weaponized?

---

## Implementation Guide

### Step 1: CI/CD SBOM Generation

```yaml
name: SBOM Security Pipeline
on:
  push:
    branches: [main]

jobs:
  generate-sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate SBOM with Syft
        uses: anchore/sbom-action@v0
        with:
          format: cyclonedx-json
          output-file: sbom.cdx.json
      
      - name: Scan for vulnerabilities
        uses: aquasecurity/trivy-action@master
        with:
          input: sbom.cdx.json
          format: json
          output: vuln-report.json
      
      - name: Upload to S3
        run: |
          aws s3 cp sbom.cdx.json s3://sbom-store/${{ github.sha }}/
          aws s3 cp vuln-report.json s3://sbom-store/${{ github.sha }}/
```

### Step 2: Vulnerability Enrichment

```python
import requests
import json

def enrich_vulnerabilities(vuln_report_path):
    """Enrich vulnerability data from multiple sources."""
    with open(vuln_report_path) as f:
        vulns = json.load(f)
    
    enriched = []
    for result in vulns.get("Results", []):
        for v in result.get("Vulnerabilities", []):
            cve_id = v.get("VulnerabilityID")
            osv_resp = requests.post(
                "https://api.osv.dev/v1/vulns",
                json={"id": cve_id}
            )
            enriched.append({
                "cve": cve_id,
                "severity": v.get("Severity"),
                "cvss_score": v.get("CVSS", {}).get("nvd", {}).get("V3Score"),
                "package": v.get("PkgName"),
                "fixed_version": v.get("FixedVersion"),
                "osv_details": osv_resp.json() if osv_resp.ok else None
            })
    return enriched
```

### Step 3: ML Prioritization Model

```python
from sklearn.ensemble import GradientBoostingClassifier
import numpy as np

class VulnPrioritizer:
    def __init__(self):
        self.model = GradientBoostingClassifier(
            n_estimators=200, max_depth=5, learning_rate=0.1
        )
    
    def predict_priority(self, vulns):
        scored = []
        for v in vulns:
            features = np.array([
                v["cvss_score"] or 0,
                1 if v.get("exploit_available") else 0,
                self._days_since_disclosure(v),
                self._package_popularity(v["package"]),
                1 if v["fixed_version"] else 0
            ]).reshape(1, -1)
            risk = self.model.predict_proba(features)[0][1]
            v["ai_risk_score"] = round(risk, 3)
            scored.append(v)
        return sorted(scored, key=lambda x: x["ai_risk_score"], reverse=True)
```

---

## Deployment

### Prerequisites

- AWS Account with S3, DynamoDB, Lambda
- GitHub Actions enabled
- Python 3.11+

### Quick Start

```bash
# Generate SBOM locally
syft dir:. -o cyclonedx-json > sbom.json

# Scan for vulnerabilities
trivy sbom sbom.json --format json -o vulns.json

# Run AI prioritization
python prioritizer.py --input vulns.json --output prioritized.json
```

---

## Quick Reference

```bash
# Generate SBOM from container image
syft alpine:latest -o cyclonedx-json

# Scan SBOM for vulnerabilities
trivy sbom sbom.cdx.json

# Query OSV API
curl -X POST https://api.osv.dev/v1/vulns -d "{"id":"CVE-2021-44228"}"
```

### Links
- [CycloneDX Specification](https://cyclonedx.org/specification/overview/)
- [SPDX Specification](https://spdx.dev/specifications/)
- [NTIA SBOM Guidance](https://www.ntia.gov/sbom)
- [OSV.dev](https://osv.dev/)



---

<!-- PROJECT: 09-mlops-model-registry -->

# MLOps Model Registry

## Overview

> **Mentor Note**: A model registry is like a version-controlled library for machine learning models. Just as Git tracks code changes, a model registry tracks model versions, their training data, performance metrics, and deployment status - ensuring you always know which model is running where and why.

This project implements a production-grade MLOps model registry using AWS SageMaker Model Registry with custom extensions for model governance, A/B testing orchestration, and automated model promotion pipelines. It provides full lineage tracking from training data to production deployment.

### Why This Matters

- Organizations deploy dozens of ML models, each requiring version control
- Regulatory requirements demand model explainability and audit trails
- Model performance degrades over time (concept drift) and needs monitoring
- Reproducibility is critical for debugging and compliance

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  Training        |---->|  Model Registry  |---->|  Deployment      |
|  Pipeline        |     |  (SageMaker)     |     |  Pipeline        |
|  (SageMaker Jobs)|     |                  |     |  (Step Functions)|
+------------------+     +------------------+     +------------------+
         |                        |                        |
         v                        v                        v
+------------------+     +------------------+     +------------------+
|  Experiment      |     |  Model Card      |     |  A/B Testing     |
|  Tracking        |     |  (Governance)    |     |  Orchestration   |
|  (MLflow)        |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Model Storage | SageMaker Model Registry | Version and catalog models |
| Experiment Tracking | MLflow | Track training runs and metrics |
| Model Cards | Custom Python | Governance documentation |
| Promotion Pipeline | Step Functions | Automated model promotion |
| A/B Testing | SageMaker Endpoints | Compare model performance |
| Monitoring | CloudWatch + Custom | Detect model drift |

---

## Core Concepts

### Model Lifecycle Stages

| Stage | Description | Gate Criteria |
|-------|-----------|---------------|
| **Development** | Initial training and experimentation | Metrics above baseline |
| **Staging** | Validation on holdout data | Passes bias and fairness checks |
| **Production** | Serving live traffic | Approved by model review board |
| **Archived** | Retired from production | Replacement model deployed |

### Model Governance Requirements

1. **Lineage** - Track data, code, and parameters for every model version
2. **Explainability** - SHAP values or feature importance for all models
3. **Bias Detection** - Fairness metrics across protected attributes
4. **Performance Monitoring** - Real-time accuracy and latency tracking

---

## Implementation Guide

### Step 1: Register Model in SageMaker

```python
import boto3
import sagemaker
from sagemaker.model_metrics import ModelMetrics, MetricsSource

def register_model(model_artifact, metrics, model_package_group):
    """Register a trained model with full metadata."""
    sm = sagemaker.Session()
    
    model_metrics = ModelMetrics(
        model_statistics=MetricsSource(
            s3_uri=metrics["statistics_uri"],
            content_type="application/json"
        ),
        bias=MetricsSource(
            s3_uri=metrics["bias_uri"],
            content_type="application/json"
        ),
        explainability=MetricsSource(
            s3_uri=metrics["explainability_uri"],
            content_type="application/json"
        )
    )
    
    model_package = sm.sagemaker_client.create_model_package(
        ModelPackageGroupName=model_package_group,
        InferenceSpecification={
            "Containers": [{
                "Image": "ACCOUNT.dkr.ecr.REGION.amazonaws.com/model:latest",
                "ModelDataUrl": model_artifact
            }],
            "SupportedContentTypes": ["application/json"],
            "SupportedResponseMIMETypes": ["application/json"]
        },
        ModelMetrics=model_metrics,
        ModelApprovalStatus="PendingManualApproval"
    )
    
    return model_package["ModelPackageArn"]
```

### Step 2: Automated Promotion Pipeline

```python
def promote_model(model_package_arn, target_stage):
    """Promote model through lifecycle stages with validation."""
    sm = boto3.client("sagemaker")
    
    # Validate promotion criteria
    package = sm.describe_model_package(ModelPackageName=model_package_arn)
    metrics = evaluate_model_metrics(package)
    
    if not meets_promotion_criteria(metrics, target_stage):
        raise ValueError(f"Model does not meet {target_stage} criteria")
    
    # Update approval status
    sm.update_model_package(
        ModelPackageArn=model_package_arn,
        ModelApprovalStatus="Approved",
        ApprovalDescription=f"Auto-promoted to {target_stage}"
    )
    
    # Deploy to target environment
    if target_stage == "Production":
        deploy_to_endpoint(model_package_arn, "prod-endpoint")
```

### Step 3: Model Drift Detection

```python
def check_model_drift(endpoint_name, baseline_metrics):
    """Monitor model performance and detect drift."""
    current_metrics = get_endpoint_metrics(endpoint_name)
    
    drift_detected = False
    for metric, baseline in baseline_metrics.items():
        current = current_metrics.get(metric, 0)
        drift_pct = abs(current - baseline) / baseline * 100
        
        if drift_pct > DRIFT_THRESHOLD:
            drift_detected = True
            alert_model_drift(endpoint_name, metric, baseline, current)
    
    return drift_detected
```

---

## Deployment

### Prerequisites

- AWS SageMaker access
- MLflow server (or SageMaker Experiments)
- Python 3.11+ with sagemaker SDK

### Quick Start

```bash
# Create model package group
python create_registry.py --group fraud-detection-models

# Register a trained model
python register_model.py --artifact s3://models/latest/model.tar.gz

# Check model status
aws sagemaker list-model-packages --model-package-group-name fraud-detection-models
```

---

## Quick Reference

| Task | Command |
|------|--------|
| List model groups | `aws sagemaker list-model-package-groups` |
| List model versions | `aws sagemaker list-model-packages --model-package-group <name>` |
| Approve model | `aws sagemaker update-model-package --model-package-arn <arn> --model-approval-status Approved` |
| Describe model | `aws sagemaker describe-model-package --model-package-name <arn>` |

### Links
- [SageMaker Model Registry](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry.html)
- [MLflow Model Registry](https://mlflow.org/docs/latest/model-registry.html)
- [ML Model Governance](https://aws.amazon.com/blogs/machine-learning/)



---

<!-- PROJECT: 10-serverless-data-pipeline -->

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



---

<!-- PROJECT: 11-supply-chain-risk-api -->

# Supply Chain Risk API

## Overview

> **Mentor Note**: Software supply chain security is about knowing and trusting every component in your software, just like food safety tracks ingredients from farm to table. This API provides a centralized service for evaluating the security risk of open-source dependencies before they enter your codebase.

This project implements a RESTful API service that evaluates software supply chain risk by analyzing package metadata, vulnerability history, maintainer reputation, and dependency graphs. It integrates with CI/CD pipelines to automatically gate deployments based on supply chain risk scores.

### Why This Matters

- Supply chain attacks increased 742% from 2019 to 2022
- SolarWinds, Log4Shell, and CodeCov demonstrated catastrophic impact
- Executive Order 14028 mandates supply chain security for federal software
- Organizations need automated risk assessment at scale

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  CI/CD Pipeline  |---->|  API Gateway     |---->|  Risk Engine     |
|  (GitHub Actions)|     |  (REST API)      |     |  (Lambda/ECS)    |
+------------------+     +------------------+     +------------------+
                                                         |
                                  +----------------------+
                                  |          |           |
                                  v          v           v
                          +----------+ +----------+ +----------+
                          | Package  | | Vuln     | | Maintainer|
                          | Metadata | | History  | | Analysis  |
                          +----------+ +----------+ +----------+
                                  |          |           |
                                  v          v           v
                          +----------------------------------+
                          |       Composite Risk Score       |
                          +----------------------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| API Layer | API Gateway + Lambda | RESTful interface for risk queries |
| Risk Engine | Python (FastAPI) | Calculate composite risk scores |
| Package Analysis | Custom crawlers | Gather package metadata |
| Vulnerability DB | DynamoDB + OSV.dev | Track known vulnerabilities |
| Maintainer Analysis | GitHub API | Assess maintainer trustworthiness |
| Dependency Graph | Neo4j / DynamoDB | Map transitive dependencies |

---

## Core Concepts

### Risk Score Components

| Factor | Weight | Description |
|--------|--------|-------------|
| **Vulnerability History** | 30% | Number and severity of past CVEs |
| **Maintainer Trust** | 25% | Account age, activity, 2FA enabled |
| **Dependency Depth** | 20% | Transitive dependency count and risk |
| **Package Popularity** | 15% | Download count, GitHub stars, forks |
| **License Compliance** | 10% | License compatibility and restrictions |

### Risk Levels

| Score | Level | Action |
|-------|-------|--------|
| 0-30 | Low | Auto-approve |
| 31-60 | Medium | Flag for review |
| 61-80 | High | Require approval |
| 81-100 | Critical | Block deployment |

---

## Implementation Guide

### Step 1: FastAPI Risk Engine

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Supply Chain Risk API")

class PackageRequest(BaseModel):
    name: str
    version: str
    ecosystem: str  # npm, pypi, maven

class RiskResponse(BaseModel):
    package: str
    version: str
    risk_score: float
    risk_level: str
    factors: dict
    recommendation: str

@app.post("/api/v1/assess", response_model=RiskResponse)
async def assess_package(request: PackageRequest):
    """Assess supply chain risk for a package."""
    vuln_score = await check_vulnerabilities(request)
    maintainer_score = await analyze_maintainer(request)
    dependency_score = await analyze_dependencies(request)
    popularity_score = await check_popularity(request)
    license_score = await check_license(request)
    
    composite = (
        vuln_score * 0.30 +
        maintainer_score * 0.25 +
        dependency_score * 0.20 +
        popularity_score * 0.15 +
        license_score * 0.10
    )
    
    return RiskResponse(
        package=request.name,
        version=request.version,
        risk_score=round(composite, 2),
        risk_level=get_risk_level(composite),
        factors={
            "vulnerability": vuln_score,
            "maintainer": maintainer_score,
            "dependencies": dependency_score,
            "popularity": popularity_score,
            "license": license_score
        },
        recommendation=get_recommendation(composite)
    )
```

### Step 2: CI/CD Integration

```yaml
name: Supply Chain Check
on: pull_request

jobs:
  risk-assessment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Extract dependencies
        run: pip freeze > requirements.txt
      
      - name: Assess supply chain risk
        run: |
          while IFS= read -r dep; do
            pkg=$(echo $dep | cut -d= -f1)
            ver=$(echo $dep | cut -d= -f3)
            result=$(curl -s -X POST $API_URL/api/v1/assess \
              -H "Content-Type: application/json" \
              -d "{\"name\":\"$pkg\",\"version\":\"$ver\",\"ecosystem\":\"pypi\"}")
            score=$(echo $result | jq '.risk_score')
            if (( $(echo "$score > 80" | bc -l) )); then
              echo "BLOCKED: $pkg@$ver (risk: $score)"
              exit 1
            fi
          done < requirements.txt
```

### Step 3: Vulnerability Analysis

```python
async def check_vulnerabilities(package):
    """Query multiple vulnerability databases."""
    vulns = []
    
    # Query OSV.dev
    osv_resp = await query_osv(package.name, package.version, package.ecosystem)
    vulns.extend(osv_resp)
    
    # Query NVD
    nvd_resp = await query_nvd(package.name)
    vulns.extend(nvd_resp)
    
    # Calculate score based on severity and recency
    if not vulns:
        return 0  # No known vulnerabilities
    
    critical = sum(1 for v in vulns if v["severity"] == "CRITICAL")
    high = sum(1 for v in vulns if v["severity"] == "HIGH")
    
    return min(100, critical * 25 + high * 15 + len(vulns) * 5)
```

---

## Deployment

### Prerequisites

- AWS Account with API Gateway, Lambda, DynamoDB
- Python 3.11+ with FastAPI
- GitHub token for maintainer analysis

### Quick Start

```bash
# Deploy API infrastructure
cd terraform/supply-chain-api
terraform apply

# Test locally
uvicorn main:app --reload

# Test assessment
curl -X POST http://localhost:8000/api/v1/assess \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"requests\",\"version\":\"2.31.0\",\"ecosystem\":\"pypi\"}"
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Assess single package | `curl -X POST /api/v1/assess -d {...}` |
| Batch assessment | `curl -X POST /api/v1/assess/batch -d [...]` |
| Get risk history | `curl /api/v1/history/<package>` |
| Update vuln database | `python sync_vulns.py --source osv,nvd` |

### Links
- [OpenSSF Scorecard](https://github.com/ossf/scorecard)
- [OSV.dev API](https://osv.dev/docs/)
- [SLSA Framework](https://slsa.dev/)
- [Sigstore](https://www.sigstore.dev/)



---

<!-- PROJECT: 12-ai-threat-modeling-framework -->

# AI Threat Modeling Framework

## Overview

> **Mentor Note**: Threat modeling is like creating a security blueprint before building a house - you identify all the ways someone could break in and plan defenses in advance. This project uses AI to automate and enhance that process, analyzing system architectures to identify threats that humans might miss.

This project implements an AI-powered threat modeling framework that automatically analyzes system architectures, identifies potential threats using STRIDE methodology, and generates prioritized remediation recommendations. It integrates with architecture diagrams and infrastructure-as-code to provide continuous threat assessment.

### Why This Matters

- Manual threat modeling is time-consuming and requires expert knowledge
- Architecture changes often outpace security reviews
- STRIDE and MITRE ATT&CK mapping requires deep security expertise
- Continuous threat assessment catches risks as systems evolve

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  System Input    |---->|  AI Analysis     |---->|  Threat Report   |
|  - Architecture  |     |  Engine          |     |  Generator       |
|  - IaC (Terraform)|    |  (LLM + Rules)   |     |                  |
|  - Data Flow     |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
                                  |                        |
                                  v                        v
                          +------------------+     +------------------+
                          |  STRIDE Analysis |     |  MITRE ATT&CK   |
                          |  Classifier      |     |  Mapping         |
                          +------------------+     +------------------+
                                  |                        |
                                  v                        v
                          +----------------------------------+
                          |  Prioritized Threat Matrix       |
                          |  with Remediation Guidance       |
                          +----------------------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Input Parser | Python + HCL parser | Parse architecture and IaC inputs |
| AI Engine | LLM (GPT-4/Claude) + Rules | Identify threats and attack vectors |
| STRIDE Classifier | Custom ML model | Categorize threats by STRIDE |
| MITRE Mapper | ATT&CK API integration | Map threats to MITRE techniques |
| Report Generator | Jinja2 + Markdown | Produce actionable reports |
| Dashboard | Streamlit | Interactive threat visualization |

---

## Core Concepts

### STRIDE Threat Categories

| Category | Description | Example |
|----------|-----------|----------|
| **S**poofing | Impersonating another entity | Stolen API keys |
| **T**ampering | Modifying data in transit/rest | Man-in-the-middle attack |
| **R**epudiation | Denying actions taken | Missing audit logs |
| **I**nformation Disclosure | Exposing sensitive data | Unencrypted S3 bucket |
| **D**enial of Service | Making service unavailable | DDoS attack |
| **E**levation of Privilege | Gaining unauthorized access | IAM privilege escalation |

### Threat Modeling Process

1. **Decompose** - Break system into components and data flows
2. **Identify** - Find threats for each component using STRIDE
3. **Rate** - Assess likelihood and impact (DREAD scoring)
4. **Mitigate** - Define countermeasures for each threat
5. **Validate** - Verify mitigations are implemented

---

## Implementation Guide

### Step 1: Architecture Parser

```python
import hcl2
import json

def parse_terraform(tf_directory):
    """Extract system components from Terraform files."""
    components = []
    
    for tf_file in Path(tf_directory).glob("**/*.tf"):
        with open(tf_file) as f:
            config = hcl2.load(f)
        
        for resource_type, resources in config.get("resource", [{}])[0].items():
            for name, props in resources.items():
                components.append({
                    "type": resource_type,
                    "name": name,
                    "properties": props,
                    "data_flows": extract_data_flows(props),
                    "trust_boundary": determine_trust_boundary(resource_type)
                })
    
    return components
```

### Step 2: AI Threat Analysis

```python
from openai import OpenAI

def analyze_threats(components, data_flows):
    """Use LLM to identify threats in the architecture."""
    client = OpenAI()
    
    prompt = f"""Analyze the following cloud architecture for security threats
    using STRIDE methodology. For each threat identified, provide:
    1. STRIDE category
    2. Threat description
    3. Affected component
    4. Likelihood (1-5)
    5. Impact (1-5)
    6. MITRE ATT&CK technique ID
    7. Recommended mitigation
    
    Architecture components:
    {json.dumps(components, indent=2)}
    
    Data flows:
    {json.dumps(data_flows, indent=2)}
    """
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.2
    )
    
    return parse_threat_response(response.choices[0].message.content)
```

### Step 3: MITRE ATT&CK Mapping

```python
def map_to_mitre(threats):
    """Map identified threats to MITRE ATT&CK techniques."""
    mitre_mapping = {
        "Spoofing": ["T1078", "T1098", "T1134"],
        "Tampering": ["T1565", "T1036", "T1070"],
        "Repudiation": ["T1070.001", "T1562.001"],
        "InformationDisclosure": ["T1530", "T1552", "T1040"],
        "DenialOfService": ["T1499", "T1498"],
        "ElevationOfPrivilege": ["T1548", "T1068", "T1078.004"]
    }
    
    for threat in threats:
        category = threat["stride_category"]
        threat["mitre_techniques"] = mitre_mapping.get(category, [])
        threat["mitre_details"] = [
            fetch_mitre_technique(t) for t in threat["mitre_techniques"]
        ]
    
    return threats
```

### Step 4: Report Generation

```python
from jinja2 import Template

def generate_report(threats, output_path):
    """Generate markdown threat model report."""
    template = Template(open("templates/threat_report.md.j2").read())
    
    report = template.render(
        project_name="Target System",
        date=datetime.utcnow().strftime("%Y-%m-%d"),
        total_threats=len(threats),
        critical=len([t for t in threats if t["risk_score"] > 20]),
        high=len([t for t in threats if 15 < t["risk_score"] <= 20]),
        threats=sorted(threats, key=lambda t: t["risk_score"], reverse=True)
    )
    
    with open(output_path, "w") as f:
        f.write(report)
```

---

## Deployment

### Prerequisites

- Python 3.11+
- OpenAI API key (or AWS Bedrock for Claude)
- Terraform files or architecture diagrams as input

### Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Analyze Terraform directory
python threat_model.py --input terraform/ --output report.md

# Run interactive dashboard
streamlit run dashboard.py

# Generate STRIDE analysis
python stride_analysis.py --architecture arch.json
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Full threat model | `python threat_model.py --input <dir> --output report.md` |
| STRIDE only | `python stride_analysis.py --architecture arch.json` |
| MITRE mapping | `python mitre_mapper.py --threats threats.json` |
| Interactive mode | `streamlit run dashboard.py` |

### Links
- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [STRIDE Methodology](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [Threat Modeling Manifesto](https://www.threatmodelingmanifesto.org/)

