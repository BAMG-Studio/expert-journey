<!-- Badges -->
![AWS](https://img.shields.io/badge/AWS-Security-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Security](https://img.shields.io/badge/Security-TS%2FSCI_Cleared-DC143C?style=for-the-badge&logo=hackaday&logoColor=white)
![FedRAMP](https://img.shields.io/badge/FedRAMP-Moderate-005EA2?style=for-the-badge&logo=gov&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

# AWS Security Engineering Portfolio

> **Production-grade security engineering across AWS cloud infrastructure, DevSecOps automation, and AI/ML security pipelines -- built for organizations supporting U.S. government and FedRAMP workloads.**

---

## About

I am a security engineer with **7+ years of hands-on AWS experience** designing, implementing, and automating security controls for mission-critical systems. My work spans multi-account AWS governance, FedRAMP continuous monitoring, incident response orchestration, and emerging AI/ML security disciplines.

I hold an **active TS/SCI security clearance** and have delivered security solutions for programs subject to NIST 800-53, FedRAMP, RMF, and CMMC compliance frameworks.

This repository serves as a living portfolio of **12 end-to-end projects** -- each on its own branch -- demonstrating production-grade implementations with architecture design, secure code, deployment automation, and comprehensive documentation.

**Contact:** [peter@beaconagile.net](mailto:peter@beaconagile.net)

---

## Skills at a Glance

| Domain | Technologies |
|---|---|
| **Cloud Security** | GuardDuty, Security Hub, AWS Config, CloudTrail, Macie, IAM, KMS, Organizations, Control Tower |
| **DevSecOps** | Terraform, Terragrunt, Ansible, GitHub Actions, Checkov, tfsec, Snyk |
| **Application Security** | SAST/SCA pipelines, secret scanning, dependency analysis, SBOM generation (Syft), vulnerability scanning (Grype, Trivy) |
| **AI/ML Security** | SageMaker, MLflow, model signing (cosign), ML supply-chain integrity, AI threat modeling |
| **Incident Response** | EventBridge, Lambda, Step Functions, automated playbooks, SIEM integration |
| **Container Security** | EKS, Kyverno, ECR image scanning, pod security standards |
| **Compliance** | NIST 800-53 Rev 5, FedRAMP Moderate, RMF, CMMC, DISA STIGs |

Full skills-to-project mapping: [`SKILLS_MATRIX.md`](./SKILLS_MATRIX.md)

---

## Project Index

Each project branch contains: architecture docs, Terraform/IaC modules, automation code, CI/CD workflows, security controls, and NIST 800-53 mappings.

| # | Branch | Project | Key Technologies |
|---|---|---|---|
| 1 | `ai-security-sbom-pipeline` | AI Security SBOM Pipeline | Syft, Grype, cosign, SageMaker, GitHub Actions |
| 2 | `fedramp-compliance-automation` | FedRAMP Compliance Automation | AWS Config, Security Hub, NIST 800-53, Lambda |
| 3 | `incident-response-orchestration` | Incident Response Orchestration | EventBridge, Step Functions, Lambda, SNS |
| 4 | `multi-account-aws-governance` | Multi-Account AWS Governance | Organizations, SCPs, Control Tower, Guardrails |
| 5 | `enterprise-siem-pipeline` | Enterprise SIEM Pipeline | CloudTrail, Macie, GuardDuty, OpenSearch, Kinesis |
| 6 | `mlops-model-registry-security` | MLOps Model Registry Security | SageMaker, MLflow, IAM, KMS, cosign |
| 7 | `infrastructure-drift-detection` | Infrastructure Drift Detection | Terraform, AWS Config, Lambda, EventBridge |
| 8 | `supply-chain-risk-api` | Supply Chain Risk Scoring API | API Gateway, Lambda, DynamoDB, WAF |
| 9 | `kubernetes-security-eks` | Kubernetes Security (EKS) | EKS, Kyverno, Falco, ECR, pod security |
| 10 | `terraform-policy-enforcement` | Terraform Policy Enforcement | Checkov, tfsec, OPA, Sentinel, GitHub Actions |
| 11 | `serverless-data-pipeline-security` | Serverless Data Pipeline Security | Kinesis, SQS, Lambda, KMS, Macie |
| 12 | `ai-threat-modeling-workbench` | AI Threat Modeling Workbench | STRIDE, LINDDUN, Terraform, threat models |

---

## Repository Layout

```
.
|-- README.md                    # This file
|-- ARCHITECTURE.md              # Security-first design philosophy
|-- SKILLS_MATRIX.md             # Skills-to-project mapping
|-- PROGRESS.md                  # Project dashboard and milestones
|-- docs/
|   |-- interos-alignment.md     # Role alignment mapping
|   |-- aws-architecture-patterns.md
|   |-- security-controls-library.md
|   |-- compliance-frameworks.md
|-- templates/
|   |-- project-kickoff.md
|   |-- architecture-decision-record.md
|   |-- security-checklist.md
|   |-- deployment-runbook.md
|-- .github/
|   |-- workflows/
|   |   |-- terraform-validate.yml
|   |   |-- security-scan.yml
|   |-- ISSUE_TEMPLATE/
|   |   |-- bug_report.md
|   |   |-- feature_request.md
|   |-- PULL_REQUEST_TEMPLATE.md
|-- .devcontainer/
    |-- devcontainer.json
```

---

## Architecture Principles

Every project in this portfolio adheres to:

- **Defense in Depth** -- layered security controls at network, identity, application, and data tiers
- **Zero Trust** -- verify explicitly, enforce least privilege, assume breach
- **Shift Left** -- security gates embedded in CI/CD before deployment
- **Compliance as Code** -- NIST 800-53 controls codified in Terraform, Config rules, and policies
- **Observability** -- centralized logging, metrics, and alerting for security events

Detailed architecture: [`ARCHITECTURE.md`](./ARCHITECTURE.md)

---

## Certifications & Clearance

| Credential | Status |
|---|---|
| TS/SCI Security Clearance | **Active** |
| CompTIA Security+ | Certified |
| PMP (Project Management Professional) | Certified |
| AWS Security Specialty | In Progress |
| PGP in Generative AI & Machine Learning | In Progress |

---

## Getting Started

This repository uses a **Dev Container** for reproducible environments.

1. Open in GitHub Codespaces or VS Code with the Dev Containers extension
2. The container pre-installs: AWS CLI, Terraform, Docker, Ansible, Python 3.11
3. Run `pip install -r requirements.txt` for additional Python dependencies
4. Switch branches to explore individual projects: `git checkout <branch-name>`

---

## License

This portfolio is provided for demonstration and educational purposes. Individual project implementations may reference AWS services and third-party tools under their respective licenses.

---

*Built with a security-first mindset. Every line of code, every architecture decision, every automation -- designed for production.*
