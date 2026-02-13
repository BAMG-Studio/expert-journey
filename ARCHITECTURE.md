# Architecture & Design Philosophy

This document outlines the security-first architecture principles, patterns, and frameworks applied across all 12 portfolio projects.

---

## Security-First Design Philosophy

Every system in this portfolio is designed with the principle that **security is not an afterthought** -- it is the foundation upon which reliability, compliance, and trust are built.

Core tenets:

1. **Secure by Default** -- resources deploy with least-privilege permissions, encryption enabled, and public access denied unless explicitly justified
2. **Automate Everything** -- manual security processes are error-prone; every control is codified and repeatable
3. **Fail Closed** -- when a security control encounters an ambiguous state, it denies access rather than allowing it
4. **Audit Everything** -- every action, API call, and configuration change is logged and queryable

---

## Defense-in-Depth Model

Security controls are layered across five tiers:

### Tier 1: Network & Perimeter
- VPC design with private subnets, NAT gateways, and no direct internet exposure for workloads
- AWS WAF rules on API Gateway and ALB endpoints
- Security groups scoped to minimum required ports and source CIDRs
- VPC Flow Logs enabled for network traffic analysis

### Tier 2: Identity & Access
- IAM policies enforcing least-privilege with condition keys
- Service control policies (SCPs) at the AWS Organizations level
- MFA enforcement for human access; role-based access for services
- Session policies and permission boundaries for delegated administration

### Tier 3: Application & Workload
- SAST/SCA scanning in CI/CD pipelines before deployment
- Container image scanning and signing (Trivy, cosign)
- Runtime protection with Falco and GuardDuty
- Secret management via AWS Secrets Manager and Parameter Store (SecureString)

### Tier 4: Data Protection
- Encryption at rest (KMS CMKs) and in transit (TLS 1.2+)
- S3 bucket policies denying unencrypted uploads
- Macie for sensitive data classification and monitoring
- DynamoDB encryption and point-in-time recovery enabled by default

### Tier 5: Monitoring & Response
- CloudTrail for API audit logging across all accounts
- GuardDuty for threat detection with automated response playbooks
- Security Hub for aggregated compliance scoring (CIS, PCI-DSS, NIST)
- EventBridge rules triggering Lambda-based incident response

---

## Multi-Account AWS Governance

Production architectures use AWS Organizations with a dedicated account structure:

```
Management Account (root)
|-- Security Account (GuardDuty admin, Security Hub aggregator, CloudTrail org trail)
|-- Log Archive Account (centralized logging, immutable S3 buckets)
|-- Shared Services Account (CI/CD, container registry, artifact management)
|-- Workload Accounts
    |-- Development
    |-- Staging
    |-- Production
```

Key governance controls:
- **SCPs** restrict risky actions (e.g., disabling CloudTrail, creating public S3 buckets)
- **AWS Config** org-wide rules evaluate resource compliance continuously
- **Guardrails** enforce mandatory controls (detective and preventive)
- **Cross-account IAM roles** with external ID for secure delegation

---

## Zero-Trust Architecture

Zero trust is implemented through:

- **Identity verification** at every request boundary (no implicit trust from network location)
- **Microsegmentation** using security groups and network policies (Kubernetes)
- **Continuous validation** of device posture, session tokens, and access patterns
- **Just-in-time access** for privileged operations with automatic expiration
- **Encryption everywhere** -- data is encrypted at rest, in transit, and during processing where feasible

---

## Compliance Framework Integration

### NIST 800-53 Rev 5
All projects map implemented controls to NIST 800-53 control families:
- **AC** (Access Control): IAM policies, SCPs, RBAC
- **AU** (Audit and Accountability): CloudTrail, VPC Flow Logs, S3 access logs
- **CA** (Assessment, Authorization, and Monitoring): Security Hub, Config rules
- **CM** (Configuration Management): Terraform state, drift detection, Config
- **CP** (Contingency Planning): backup policies, cross-region replication
- **IA** (Identification and Authentication): MFA, federation, certificate-based auth
- **IR** (Incident Response): automated playbooks, Step Functions, runbooks
- **RA** (Risk Assessment): threat modeling, vulnerability scanning, SBOM analysis
- **SC** (System and Communications Protection): encryption, network segmentation
- **SI** (System and Information Integrity): GuardDuty, patching, image scanning

### FedRAMP Moderate
- 325 controls baseline with continuous monitoring
- Automated evidence collection for Plan of Actions & Milestones (POA&M)
- Monthly vulnerability scanning and annual assessment readiness

Control mappings: [`docs/security-controls-library.md`](./docs/security-controls-library.md)
Framework details: [`docs/compliance-frameworks.md`](./docs/compliance-frameworks.md)
