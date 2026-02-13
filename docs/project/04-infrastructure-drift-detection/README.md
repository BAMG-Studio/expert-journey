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
