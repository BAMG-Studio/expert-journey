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
