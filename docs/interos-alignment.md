# Interos Role Alignment

Mapping of portfolio projects to key requirements for Application Security Engineer roles at Interos and similar organizations supporting U.S. government contracts.

---

## Role Requirements Mapping

| Interos Requirement | Portfolio Project(s) | Evidence |
|---|---|---|
| **AWS Security Services** (GuardDuty, Config, CloudTrail, Security Hub) | FedRAMP Automation, Incident Response, Multi-Account Governance, SIEM Pipeline | Terraform modules deploying and configuring each service; Lambda-based automation responding to findings |
| **FedRAMP Compliance** | FedRAMP Compliance Automation | Automated NIST 800-53 control assessment, Config rules mapped to control families, continuous monitoring dashboard |
| **NIST 800-53 Controls** | All projects (control mappings) | Each project includes a controls matrix mapping implementation to specific NIST 800-53 Rev 5 controls |
| **Ansible Automation** | FedRAMP Automation | Ansible playbooks for baseline configuration, STIG compliance, and remediation |
| **GitOps / CI/CD Security** | All projects | GitHub Actions workflows with security gates (Checkov, tfsec, secret scanning) |
| **Terraform / IaC** | Multi-Account Governance, Drift Detection, Policy Enforcement | Production-grade Terraform modules with Terragrunt orchestration and policy-as-code |
| **SRE / Incident Response** | Incident Response Orchestration, Enterprise SIEM | Automated playbooks using Step Functions, EventBridge routing, MTTR reduction metrics |
| **AI/ML Security** | AI Security SBOM Pipeline, MLOps Model Registry, AI Threat Modeling | Model signing, SBOM generation, vulnerability scanning for ML artifacts, STRIDE/LINDDUN threat models |
| **Kubernetes / Container Security** | Kubernetes Security (EKS) | EKS hardening, Kyverno policies, Falco runtime monitoring, image scanning |
| **Supply Chain Security** | AI Security SBOM Pipeline, Supply Chain Risk API | SBOM generation (Syft), vulnerability matching (Grype), artifact signing (cosign), risk scoring API |
| **TS/SCI Clearance** | N/A | Active clearance held |
| **Security+ / PMP** | N/A | Both certifications active |

---

## Quantified Impact Demonstrations

Each project is designed to demonstrate measurable security improvements:

- **MTTR Reduction**: Incident Response Orchestration targets 70% reduction in mean-time-to-respond through automated playbooks
- **Compliance Score**: FedRAMP Automation targets 95%+ automated compliance assessment across NIST 800-53 control families
- **Drift Detection**: Infrastructure Drift Detection targets identification within 15 minutes and auto-remediation within 1 hour
- **Vulnerability Coverage**: AI Security SBOM Pipeline provides visibility into 100% of ML pipeline dependencies
- **Cost Optimization**: Multi-Account Governance demonstrates consolidated billing and resource tagging for cost attribution

---

## Interview Discussion Points

1. **Defense in Depth**: Walk through the five-tier security model implemented across the portfolio
2. **Compliance as Code**: Demonstrate how NIST 800-53 controls are codified in Terraform and AWS Config
3. **Incident Response**: Show the end-to-end automated playbook from GuardDuty finding to remediation
4. **AI/ML Security**: Discuss emerging threats to ML pipelines and the SBOM-based mitigation approach
5. **Multi-Account Strategy**: Explain the AWS Organizations structure and SCP enforcement patterns
