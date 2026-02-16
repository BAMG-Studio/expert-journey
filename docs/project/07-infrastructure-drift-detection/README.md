# Project 07: Infrastructure Drift Detection

## Overview

Detect and remediate infrastructure drift by comparing live AWS resources against Terraform state using Lambda and EventBridge.

---

## Problem Statement

### Business Context
Modern cloud environments require infrastructure drift detection to maintain security posture and compliance. Manual processes are error-prone, slow, and don't scale.

### Current State
- Manual infrastructure drift detection processes
- Inconsistent implementation across teams
- No centralized visibility or reporting
- High operational overhead
- Compliance gaps and audit findings

### Desired State
- Automated infrastructure drift detection pipeline
- Real-time visibility and reporting
- Consistent policy enforcement
- NIST 800-53 compliance
- Reduced operational overhead by 70%

---

## Architecture

```
[Simplified architecture diagram placeholder]
Input Sources → Processing Layer → Storage/Output → Monitoring
```

---

## Key Technologies

| Technology | Role | Skill Level |
|-----------|------|-------------|
| Terraform | Core technology | Advanced |
| AWS Config | Core technology | Advanced |
| Lambda | Core technology | Advanced |
| EventBridge | Core technology | Advanced |
| SNS | Core technology | Advanced |

---

## NIST 800-53 Control Mappings

- **CM-3**: Implementation via Infrastructure Drift Detection
- **CM-6**: Implementation via Infrastructure Drift Detection
- **SI-4**: Implementation via Infrastructure Drift Detection
- **AU-6**: Implementation via Infrastructure Drift Detection

---

## Key Features

- Real-time drift detection
- Automated remediation
- Drift reporting dashboard
- Alert notifications

---

## Success Criteria

- [ ] Core functionality deployed and operational
- [ ] All NIST 800-53 controls implemented
- [ ] Automated testing passing
- [ ] Documentation complete
- [ ] Performance targets met

---

## Getting Started

```bash
git checkout infrastructure-drift-detection
cd terraform/
terraform init && terraform apply
```

See [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) for detailed instructions.
