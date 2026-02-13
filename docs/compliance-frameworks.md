# Compliance Frameworks

Overview of compliance frameworks referenced and implemented across portfolio projects.

---

## NIST 800-53 Rev 5

**Scope**: Primary compliance framework for all projects.

NIST Special Publication 800-53 Rev 5 defines security and privacy controls for federal information systems. This portfolio implements controls across the following families:

- **AC** - Access Control (21 controls)
- **AU** - Audit and Accountability (16 controls)
- **CA** - Assessment, Authorization, and Monitoring (9 controls)
- **CM** - Configuration Management (14 controls)
- **CP** - Contingency Planning (13 controls)
- **IA** - Identification and Authentication (12 controls)
- **IR** - Incident Response (10 controls)
- **MA** - Maintenance (6 controls)
- **MP** - Media Protection (8 controls)
- **PE** - Physical and Environmental Protection (23 controls)
- **PL** - Planning (11 controls)
- **PS** - Personnel Security (9 controls)
- **RA** - Risk Assessment (7 controls)
- **SA** - System and Services Acquisition (23 controls)
- **SC** - System and Communications Protection (44 controls)
- **SI** - System and Information Integrity (23 controls)

Detailed control implementations: [`security-controls-library.md`](./security-controls-library.md)

---

## FedRAMP Moderate

**Scope**: FedRAMP Compliance Automation project.

FedRAMP Moderate baseline requires 325 controls from NIST 800-53. Key areas automated in this portfolio:

- **Continuous Monitoring**: AWS Config rules providing real-time compliance assessment
- **POA&M Management**: Automated tracking of remediation items with target dates
- **Annual Assessment Readiness**: Evidence collection automation for 3PAO assessments
- **Incident Response**: Documented and automated IR procedures per FedRAMP requirements
- **Vulnerability Management**: Monthly scanning with 30-day remediation SLAs for high findings

---

## DISA STIGs

**Scope**: FedRAMP Automation (Ansible playbooks).

Defense Information Systems Agency (DISA) Security Technical Implementation Guides provide hardening standards for operating systems, applications, and network devices. Implementation includes:

- Ansible roles applying STIG baselines to EC2 instances
- Automated STIG compliance checking with OpenSCAP
- Remediation playbooks for common STIG findings

---

## Risk Management Framework (RMF)

**Scope**: Multi-Account Governance, FedRAMP Automation.

The NIST Risk Management Framework (SP 800-37) defines the process for managing security risk:

1. **Categorize** - System categorization (FIPS 199)
2. **Select** - Control selection based on impact level
3. **Implement** - Control implementation (this portfolio)
4. **Assess** - Control effectiveness assessment
5. **Authorize** - Risk acceptance and ATO decision
6. **Monitor** - Continuous monitoring and reassessment

---

## CMMC (Cybersecurity Maturity Model Certification)

**Scope**: Documented mappings for supply chain security projects.

CMMC Level 2 aligns with NIST 800-171 (110 practices). Relevant portfolio implementations:

- Access control and identity management
- Audit and accountability logging
- Configuration and change management
- Incident response procedures
- Risk assessment and vulnerability management

---

## CIS Benchmarks

**Scope**: Terraform Policy Enforcement, Multi-Account Governance.

Center for Internet Security benchmarks applied:
- CIS AWS Foundations Benchmark v3.0
- CIS Kubernetes Benchmark v1.8
- CIS Docker Benchmark v1.6

Enforced through Checkov policies and AWS Config conformance packs.
