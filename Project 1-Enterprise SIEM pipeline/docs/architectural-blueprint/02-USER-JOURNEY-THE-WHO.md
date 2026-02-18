# 2. The User Journey (The "Who")
## Actors & Personas

---

## 2.1 Primary Personas

### Persona 1: Sarah Chen - Security Operations Center (SOC) Analyst

**Demographics:**
- Role: Tier 2 SOC Analyst
- Experience: 4 years in cybersecurity
- Team: 8-person SOC team (24/7 coverage)

**Goals:**
- Quickly triage and investigate security alerts
- Correlate events across multiple data sources
- Meet SLA: respond to critical alerts within 15 minutes

**Pain Points (Current State):**
- Spends 3+ hours daily hunting through 5 different AWS consoles
- No unified view of security events
- Misses critical alerts buried in noise
- Cannot easily share findings with team

**User Journey with SIEM Pipeline:**

```
[Alert Triggers]     [OpenSearch]      [Investigation]    [Response]
     |                    |                  |                |
  GuardDuty         Single pane        Correlated         Documented
  finding           of glass           timeline            incident
     |                    |                  |                |
  Severity 8        Dashboard          Related              Closed
  detected          auto-loads         events              in 12 min
                                       surfaced
```

**Success Metrics:**
- MTTR reduced from 4 hours to 12 minutes
- Alert-to-investigation time: < 30 seconds
- False positive rate: < 5%

---

### Persona 2: Marcus Williams - Cloud Security Engineer

**Demographics:**
- Role: Senior Cloud Security Engineer
- Experience: 7 years (AWS certified)
- Responsibilities: Security architecture, compliance, automation

**Goals:**
- Design and maintain security infrastructure
- Ensure compliance with NIST 800-53
- Automate security operations

**Pain Points (Current State):**
- Manual compliance evidence collection (40 hours/audit)
- No infrastructure-as-code for security controls
- Difficult to prove control effectiveness

**User Journey with SIEM Pipeline:**

```
[Terraform]        [Automated]        [Evidence]         [Audit]
     |                 |                  |                 |
  IaC deploys      Controls          Reports              Pass
  compliant        continuously      auto-generated       audit
  infra            monitored                              zero findings
```

**Success Metrics:**
- Audit prep time: 40 hours -> 4 hours
- Control drift detection: real-time
- Infrastructure deployment: fully automated

---

### Persona 3: Jennifer Park - CISO

**Demographics:**
- Role: Chief Information Security Officer
- Reports to: CEO, Board of Directors
- Focus: Risk management, strategy, compliance

**Goals:**
- Demonstrate security posture to board
- Reduce organizational risk
- Maintain compliance certifications

**Pain Points (Current State):**
- No executive-level security dashboard
- Cannot quantify risk reduction
- Compliance status unclear between audits

**User Journey with SIEM Pipeline:**

```
[Monthly Review]   [Executive]        [Board]            [Decisions]
     |             Dashboard           Report               |
  One click       Risk metrics       Trend analysis     Data-driven
  access          visualized         automated          investments
```

**Success Metrics:**
- Real-time compliance posture visibility
- Risk metrics dashboard updated continuously
- Board reports generated in < 1 hour

---

## 2.2 Secondary Actors

| Actor | System Interaction | Frequency |
|-------|-------------------|------------|
| External Auditor | Read-only access to compliance dashboards | Quarterly |
| DevOps Engineer | Receives security alerts for owned services | As needed |
| Incident Commander | Coordinates response using SIEM data | During incidents |
| Legal/Privacy | Reviews audit logs for investigations | Monthly |

---

## 2.3 User Journey Map

### Critical User Flow: Incident Investigation

```
Phase:      DETECT           TRIAGE           INVESTIGATE       RESPOND
            |
[GuardDuty] ---> [EventBridge] ---> [Firehose] ---> [OpenSearch]
            |        |                |                 |
            v        v                v                 v
         Finding   Alert          Normalized         Dashboard
         created   routed         enriched           searchable
            |        |                |                 |
            +--------+----------------+-----------------+
                            |
                            v
                    SOC Analyst Sarah
                            |
            +---------------+---------------+
            |               |               |
        View Alert    Pivot Search    Export Report
            |               |               |
        (5 sec)        (15 sec)        (10 sec)
            |               |               |
            +---------------+---------------+
                            |
                            v
                    Incident Resolved
                      (12 min total)
```

---

*Document Version: 1.0 | Author: Peter Kolawole | Last Updated: February 2026*
