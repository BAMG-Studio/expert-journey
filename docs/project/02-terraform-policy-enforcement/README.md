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
