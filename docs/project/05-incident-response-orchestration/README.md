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
