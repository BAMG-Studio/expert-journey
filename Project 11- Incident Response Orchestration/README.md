# Incident Response Orchestration

**An automated security incident response platform that orchestrates detection, triage, containment, eradication, and recovery workflows using SOAR principles, integrating with AWS security services, ticketing systems, and communication platforms for rapid incident resolution.**

## Architecture Overview

This project implements a Security Orchestration, Automation, and Response (SOAR) platform purpose-built for cloud environments. It ingests security alerts from multiple detection sources, correlates them into incidents, executes automated response playbooks, and provides a unified incident management interface with full audit trail and post-incident reporting.

### Core Components

- **Alert Ingestion Engine** - Multi-source alert collection from GuardDuty, SecurityHub, CloudWatch, third-party SIEM, and custom detectors
- **Correlation Engine** - Intelligent alert grouping and deduplication that reduces alert fatigue by 90%
- **Playbook Engine** - YAML-defined automated response playbooks with conditional logic, approval gates, and parallel execution
- **Containment Orchestrator** - Automated containment actions (isolate instance, revoke credentials, block IP) with rollback capability
- **Evidence Collector** - Automated forensic evidence preservation including memory dumps, disk snapshots, and log collection
- **Communication Manager** - Automated stakeholder notification via Slack, PagerDuty, email, and war room creation
- **Post-Incident Analyzer** - Automated timeline reconstruction, root cause analysis assistance, and lessons-learned generation

### Technology Stack

| Component | Technology |
|-----------|------------|
| Orchestration | AWS Step Functions, custom Python engine |
| Alert Sources | GuardDuty, SecurityHub, CloudWatch, Falco |
| Playbook Format | YAML with Jinja2 templating |
| Containment | AWS Lambda, Systems Manager, WAF, NACLs |
| Evidence Storage | S3 (forensic vault), EBS snapshots |
| Ticketing | Jira, ServiceNow, PagerDuty |
| Communication | Slack, Microsoft Teams, SNS, SES |
| Database | PostgreSQL, DynamoDB (state), Elasticsearch |
| API | FastAPI, WebSocket (real-time updates) |
| Dashboard | React, D3.js (incident timeline) |
| CI/CD | GitHub Actions |

## Incident Severity Matrix

| Severity | Response Time | Auto-Contain | Approval Required | Escalation |
|----------|--------------|-------------|-------------------|------------|
| P1 - Critical | < 5 min | Yes (immediate) | No (auto-execute) | VP Security + CISO |
| P2 - High | < 15 min | Yes (with notification) | No | Security Lead |
| P3 - Medium | < 1 hour | Select actions only | Yes (Security Lead) | Security Team |
| P4 - Low | < 4 hours | No | Yes | On-call analyst |
| P5 - Informational | Next business day | No | No | Logged only |

## Playbook Library

| Playbook | Trigger | Actions | Mean Time to Contain |
|----------|---------|---------|---------------------|
| Compromised EC2 | GuardDuty finding | Isolate, snapshot, revoke keys | < 3 min |
| Exposed Credentials | GuardDuty/custom | Rotate keys, audit usage, block | < 2 min |
| Unauthorized API Call | CloudTrail anomaly | Revoke session, notify, investigate | < 5 min |
| S3 Data Exfiltration | Macie + CloudTrail | Block access, snapshot bucket, alert | < 4 min |
| DDoS Attack | Shield/WAF alerts | Enable rate limiting, scale, notify | < 1 min |
| Ransomware Detection | GuardDuty + custom | Isolate, snapshot, disconnect, alert | < 2 min |
| Insider Threat | Custom behavioral | Log enhancement, session recording | < 10 min |
| Supply Chain Attack | SBOM pipeline alert | Quarantine artifact, block deploy | < 5 min |

## Prerequisites

- AWS account with GuardDuty and SecurityHub enabled
- Python >= 3.11
- Docker >= 24.0
- PostgreSQL >= 15
- Elasticsearch >= 8.0
- Slack workspace (for notifications)
- PagerDuty account (for on-call routing)

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 11- Incident Response Orchestration"

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Set AWS credentials, Slack webhook, PagerDuty API key

# Start infrastructure
docker-compose up -d
```

### 2. Deploy Response Infrastructure

```bash
# Deploy Lambda containment functions
cd terraform
terraform init
terraform apply -var-file=environments/prod.tfvars

# Deploy EventBridge rules for alert ingestion
python deploy/eventbridge_rules.py --sources guardduty,securityhub,cloudwatch

# Load playbook library
python playbooks/load.py --directory playbooks/library/
```

### 3. Test with Simulated Incident

```bash
# Run incident simulation
python simulation/run.py --scenario compromised-ec2 --dry-run

# Trigger a test alert
python testing/generate_alert.py --type guardduty --finding-type UnauthorizedAccess

# View incident dashboard
python dashboard/serve.py --port 3000
```

## Project Structure

```
Project 11- Incident Response Orchestration/
|-- orchestrator/
|   |-- engine.py                  # Main orchestration engine
|   |-- state_machine.py           # Step Functions integration
|   |-- incident_manager.py        # Incident lifecycle manager
|   |-- alert_processor.py         # Alert ingestion and processing
|-- correlation/
|   |-- correlator.py              # Alert correlation engine
|   |-- deduplication.py           # Alert deduplication logic
|   |-- enrichment.py              # Alert enrichment with context
|-- playbooks/
|   |-- engine.py                  # Playbook execution engine
|   |-- parser.py                  # YAML playbook parser
|   |-- library/
|   |   |-- compromised_ec2.yml    # EC2 compromise response
|   |   |-- exposed_credentials.yml # Credential exposure response
|   |   |-- data_exfiltration.yml  # Data exfiltration response
|   |   |-- ddos_response.yml      # DDoS mitigation
|   |   |-- ransomware.yml         # Ransomware response
|-- containment/
|   |-- actions/
|   |   |-- isolate_instance.py    # EC2 network isolation
|   |   |-- revoke_credentials.py  # IAM key revocation
|   |   |-- block_ip.py            # WAF/NACL IP blocking
|   |   |-- quarantine_role.py     # IAM role quarantine
|   |-- rollback.py                # Containment rollback manager
|-- evidence/
|   |-- collector.py               # Forensic evidence collector
|   |-- memory_dump.py             # EC2 memory acquisition
|   |-- disk_snapshot.py           # EBS snapshot manager
|   |-- log_collector.py           # CloudTrail/VPC flow log collector
|   |-- chain_of_custody.py        # Evidence chain of custody
|-- communication/
|   |-- notifier.py                # Multi-channel notification
|   |-- slack_integration.py       # Slack war room manager
|   |-- pagerduty_integration.py   # PagerDuty escalation
|   |-- email_templates/           # Email notification templates
|-- post_incident/
|   |-- timeline.py                # Incident timeline builder
|   |-- root_cause.py              # Root cause analysis assistant
|   |-- report_generator.py        # Post-incident report generator
|   |-- lessons_learned.py         # Lessons learned tracker
|-- dashboard/
|   |-- src/                       # React frontend
|   |-- components/                # UI components
|   |-- serve.py                   # Dashboard server
|-- simulation/
|   |-- run.py                     # Incident simulation runner
|   |-- scenarios/                 # Simulation scenario definitions
|-- tests/
|   |-- unit/                      # Unit tests
|   |-- integration/               # Integration tests
|   |-- playbook_tests/            # Playbook validation tests
|-- .github/
|   |-- workflows/                 # CI/CD pipeline definitions
|-- docker-compose.yml
|-- requirements.txt
|-- README.md
```

## Incident Response Workflow

1. **Detection** - Alert received from security service or custom detector
2. **Ingestion** - Alert parsed, normalized, and enriched with context
3. **Correlation** - Alert grouped with related alerts into incident
4. **Triage** - Severity assigned, playbook selected automatically
5. **Containment** - Automated containment actions executed per playbook
6. **Evidence** - Forensic evidence automatically preserved
7. **Notification** - Stakeholders notified, war room created
8. **Investigation** - Analysts provided with enriched incident data
9. **Eradication** - Root cause eliminated, systems cleaned
10. **Recovery** - Services restored, containment rolled back
11. **Post-Incident** - Timeline, report, and lessons learned generated

## Cost Estimates

| Environment | Monthly Cost |
|-------------|-------------|
| Local Development | $0 (Docker) |
| Dev/Test | ~$100-300 |
| Production | ~$500-2,000 |

## License

MIT License
