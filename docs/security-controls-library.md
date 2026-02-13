# Security Controls Library

Catalog of NIST 800-53 Rev 5 controls implemented across portfolio projects.

---

## Access Control (AC)

| Control ID | Control Name | Implementation | Project(s) |
|---|---|---|---|
| AC-2 | Account Management | IAM user/role lifecycle automation, SSO integration | Multi-Account Governance |
| AC-3 | Access Enforcement | IAM policies, SCPs, resource-based policies | All projects |
| AC-4 | Information Flow Enforcement | Security groups, NACLs, VPC endpoints | Multi-Account Governance |
| AC-6 | Least Privilege | Scoped IAM policies, permission boundaries | All projects |
| AC-17 | Remote Access | VPN, Session Manager, bastion-free access | Multi-Account Governance |

## Audit and Accountability (AU)

| Control ID | Control Name | Implementation | Project(s) |
|---|---|---|---|
| AU-2 | Event Logging | CloudTrail (org trail), VPC Flow Logs, S3 access logs | Enterprise SIEM, Multi-Account Governance |
| AU-3 | Content of Audit Records | Structured JSON logging with context enrichment | Enterprise SIEM |
| AU-6 | Audit Record Review | Security Hub insights, OpenSearch dashboards | Enterprise SIEM, FedRAMP Automation |
| AU-9 | Protection of Audit Information | Immutable S3 buckets (Object Lock), KMS encryption | Enterprise SIEM |
| AU-12 | Audit Record Generation | CloudTrail, Config, GuardDuty enabled org-wide | All projects |

## Configuration Management (CM)

| Control ID | Control Name | Implementation | Project(s) |
|---|---|---|---|
| CM-2 | Baseline Configuration | Terraform modules as golden configurations | All IaC projects |
| CM-3 | Configuration Change Control | Git-based change management, PR reviews, CI gates | All projects |
| CM-6 | Configuration Settings | AWS Config rules, Ansible hardening playbooks | FedRAMP Automation, Drift Detection |
| CM-7 | Least Functionality | Minimal IAM permissions, stripped container images | Kubernetes Security |
| CM-8 | System Component Inventory | AWS Config resource inventory, SBOM generation | Drift Detection, AI Security SBOM |

## Incident Response (IR)

| Control ID | Control Name | Implementation | Project(s) |
|---|---|---|---|
| IR-4 | Incident Handling | Step Functions playbooks, automated containment | Incident Response |
| IR-5 | Incident Monitoring | GuardDuty, Security Hub, EventBridge alerting | Incident Response, SIEM |
| IR-6 | Incident Reporting | SNS notifications, Slack/Teams integration | Incident Response |
| IR-8 | Incident Response Plan | Documented runbooks per incident type | Incident Response |

## Risk Assessment (RA)

| Control ID | Control Name | Implementation | Project(s) |
|---|---|---|---|
| RA-5 | Vulnerability Monitoring and Scanning | Trivy, Grype, Checkov, tfsec in CI/CD | All projects |
| RA-7 | Risk Response | Automated remediation, risk scoring API | Supply Chain Risk API |

## System and Communications Protection (SC)

| Control ID | Control Name | Implementation | Project(s) |
|---|---|---|---|
| SC-7 | Boundary Protection | VPC design, WAF, security groups | Multi-Account Governance |
| SC-8 | Transmission Confidentiality | TLS 1.2+ enforcement, certificate management | All projects |
| SC-12 | Cryptographic Key Management | KMS CMKs, key rotation, key policies | Serverless Data Pipeline, MLOps |
| SC-13 | Cryptographic Protection | AES-256 encryption at rest, TLS in transit | All projects |
| SC-28 | Protection of Information at Rest | S3 SSE-KMS, EBS encryption, RDS encryption | All projects |

## System and Information Integrity (SI)

| Control ID | Control Name | Implementation | Project(s) |
|---|---|---|---|
| SI-2 | Flaw Remediation | Automated patching, dependency updates | FedRAMP Automation |
| SI-3 | Malicious Code Protection | GuardDuty malware scanning, container scanning | Kubernetes Security, SIEM |
| SI-4 | System Monitoring | CloudWatch, GuardDuty, Config compliance | All projects |
| SI-7 | Software and Information Integrity | cosign artifact signing, SBOM validation | AI Security SBOM, MLOps |
