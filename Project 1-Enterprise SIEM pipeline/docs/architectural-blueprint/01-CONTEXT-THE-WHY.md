# 1. The Context (The "Why")
## Problem Statement & Business Objectives

---

## Executive Summary

This document presents the business case and strategic rationale for implementing an Enterprise SIEM (Security Information and Event Management) Pipeline using AWS-native services. The solution addresses critical gaps in security visibility, compliance requirements, and incident response capabilities for organizations operating in regulated industries.

---

## 1.1 Business Problem Statement

### The Challenge

**Scenario**: A mid-size healthcare organization (HealthCorp Inc.) with 2,500 employees operates across 5 AWS accounts managing PHI (Protected Health Information) for 500,000+ patients. They face:

1. **Security Blind Spots**: Security events scattered across 5 AWS accounts, 12 regions, and 200+ services with no centralized visibility
2. **Compliance Pressure**: Upcoming HIPAA audit requiring evidence of continuous security monitoring (NIST 800-53 controls AU-2, AU-6, AU-9)
3. **Slow Incident Response**: Current MTTR (Mean Time to Respond) of 4+ hours due to manual log correlation
4. **Audit Trail Gaps**: No immutable audit logs meeting 7-year retention requirements
5. **Cost Concerns**: Previous SIEM vendor quoted $450K/year; need cost-effective alternative

### Current State Architecture

```
[Account 1: Production]     [Account 2: Dev]      [Account 3: Staging]
      |                          |                       |
   CloudTrail                CloudTrail               CloudTrail
   (local S3)                (local S3)              (local S3)
      |                          |                       |
   No correlation            No correlation          No correlation
      |                          |                       |
   Manual review             Manual review           Manual review
   (2-4 hours)               (when remembered)       (never)
```

**Pain Points:**
- Security team spends 60% of time on manual log hunting
- No automated alerting for critical events
- Failed last compliance audit (3 critical findings)
- 2 security incidents went undetected for 72+ hours

---

## 1.2 Business Objectives

### Primary Objectives

| # | Objective | Success Metric | Priority |
|---|-----------|----------------|----------|
| 1 | Centralize security telemetry | 100% of security logs in single dashboard | Critical |
| 2 | Reduce MTTR | < 5 minutes for critical alerts | Critical |
| 3 | Achieve NIST 800-53 compliance | Pass audit with zero critical findings | Critical |
| 4 | Ensure log immutability | 7-year retention with Object Lock | High |
| 5 | Enable proactive threat hunting | < 60-second log searchability | High |
| 6 | Reduce security operations cost | < $100K/year total solution cost | Medium |

### ROI Analysis

**Investment Required:**
- Implementation: ~160 hours engineering time
- AWS Infrastructure: ~$3,500/month (production)
- Maintenance: ~20 hours/month

**Expected Returns:**
- Avoided breach cost: $3.8M average (healthcare sector)
- Compliance fine avoidance: $1.5M (HIPAA violations)
- Security team productivity: 40% time savings (~$120K/year)
- Vendor cost avoidance: $450K/year (vs. commercial SIEM)

**3-Year ROI: 847%**

---

## 1.3 Strategic Alignment

### Alignment with NIST Cybersecurity Framework

| Function | How SIEM Pipeline Addresses |
|----------|-----------------------------|
| **IDENTIFY** | Asset discovery via CloudTrail, inventory of all AWS resources |
| **PROTECT** | Encryption (KMS), access controls (IAM), network segmentation |
| **DETECT** | Real-time GuardDuty findings, anomaly detection, threat hunting |
| **RESPOND** | Automated playbooks, EventBridge alerting, SNS notifications |
| **RECOVER** | Immutable audit trails for forensics, automated remediation |

### Compliance Framework Mapping

| Regulation | Requirement | SIEM Solution |
|------------|-------------|---------------|
| **HIPAA** | Audit controls (§164.312(b)) | CloudTrail + OpenSearch dashboards |
| **SOC 2** | Logging and monitoring | Centralized SIEM with 365-day retention |
| **FedRAMP** | Continuous monitoring (CA-7) | Real-time Security Hub integration |
| **NIST 800-53** | AU-2, AU-6, AU-9, IR-5, SI-4 | Full control implementation |

---

## 1.4 Key Stakeholders & Sign-off

| Stakeholder | Role | Interest | Sign-off |
|-------------|------|----------|----------|
| CISO | Executive Sponsor | Risk reduction, compliance | ✅ |
| VP Engineering | Technical Owner | Platform reliability | ✅ |
| Compliance Officer | Audit Lead | Regulatory adherence | ✅ |
| CFO | Budget Approver | Cost optimization | ✅ |
| SOC Manager | Operations Lead | Alert quality, workflow | ✅ |

---

## 1.5 Project Scope

### In Scope
- Multi-account log aggregation (5 accounts)
- Real-time threat detection (GuardDuty, Macie, Security Hub)
- Centralized search and dashboards (OpenSearch)
- Immutable log archival (S3 Object Lock)
- Automated alerting (EventBridge, SNS)
- NIST 800-53 compliance evidence generation

### Out of Scope (Phase 2)
- On-premises log ingestion
- Third-party SaaS log integration
- Machine learning anomaly detection
- Automated remediation playbooks

---

## 1.6 Success Criteria

### Go-Live Criteria

- [ ] All 5 AWS accounts streaming logs to central pipeline
- [ ] OpenSearch dashboards operational with < 60-second latency
- [ ] GuardDuty/Macie/Security Hub findings auto-routed
- [ ] S3 Object Lock verified (deletion attempt fails)
- [ ] Alerting tested: critical event triggers SNS within 2 minutes
- [ ] Compliance report generated showing AU control evidence
- [ ] SOC team trained on new dashboards
- [ ] Runbook documented for common scenarios

---

*Document Version: 1.0 | Author: Peter Kolawole | Last Updated: February 2026*
