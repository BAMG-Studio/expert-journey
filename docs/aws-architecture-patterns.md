# AWS Architecture Patterns

Reusable security architecture patterns implemented across portfolio projects.

---

## Pattern 1: Serverless Incident Response

**Problem**: Security findings from GuardDuty, Config, and Security Hub require rapid, consistent response that manual processes cannot achieve.

**Solution**: Event-driven architecture using EventBridge, Lambda, and Step Functions.

**Flow**:
1. GuardDuty generates a finding (e.g., compromised EC2 instance)
2. EventBridge rule matches the finding pattern and severity
3. Lambda function enriches the finding with asset context (tags, owner, account)
4. Step Functions orchestrate the response: isolate resource, snapshot evidence, notify team
5. SNS delivers alerts to security operations; Slack/Teams integration for ChatOps

**Key Design Decisions**:
- Step Functions for orchestration (not Lambda chaining) to enable retries, parallel execution, and audit trails
- Separate Lambda functions per action (isolate, snapshot, notify) for testability
- Dead-letter queues for failed processing to prevent event loss
- Cross-account EventBridge bus for centralized response from any workload account

**Demonstrating Project**: `incident-response-orchestration`

---

## Pattern 2: Multi-Account Security Governance

**Problem**: Enterprise AWS environments require centralized security visibility and enforcement across dozens or hundreds of accounts.

**Solution**: AWS Organizations with delegated administration, SCPs, and cross-account security service aggregation.

**Components**:
- Management Account: Organizations, SCPs, billing
- Security Account: GuardDuty administrator, Security Hub aggregator, delegated Config
- Log Archive: Organization CloudTrail, Config snapshots, VPC Flow Logs (immutable S3)
- Workload Accounts: Scoped permissions, guardrails enforced by SCPs

**Key Design Decisions**:
- SCPs deny destructive actions (disabling logging, public S3, root user usage)
- Terraform modules parameterized per account type for consistent deployment
- Cross-account IAM roles with external ID and condition keys
- Centralized tagging policy for cost allocation and ownership tracking

**Demonstrating Project**: `multi-account-aws-governance`

---

## Pattern 3: Continuous Compliance Monitoring

**Problem**: FedRAMP and NIST 800-53 require continuous evidence of control effectiveness, not point-in-time assessments.

**Solution**: AWS Config rules mapped to NIST control families with automated remediation and evidence collection.

**Components**:
- Custom and managed Config rules evaluating resource compliance
- Remediation actions (SSM Automation, Lambda) for non-compliant resources
- Security Hub custom insights aggregating compliance posture
- S3 evidence bucket with lifecycle policies for audit retention

**Key Design Decisions**:
- Config rules organized by NIST 800-53 control family (AC, AU, CM, SC, etc.)
- Remediation with approval gates for production accounts
- Monthly compliance snapshots exported for POA&M reporting
- Integration with GRC tools via API for enterprise compliance dashboards

**Demonstrating Project**: `fedramp-compliance-automation`

---

## Pattern 4: SIEM Log Aggregation

**Problem**: Security event data is scattered across accounts, services, and regions, making threat detection and investigation slow.

**Solution**: Centralized log pipeline ingesting CloudTrail, VPC Flow Logs, GuardDuty findings, and application logs into OpenSearch.

**Components**:
- Kinesis Data Firehose for log ingestion and transformation
- Lambda for log normalization and enrichment
- OpenSearch for indexing, search, and visualization
- S3 for long-term log archival (Glacier lifecycle)

**Demonstrating Project**: `enterprise-siem-pipeline`
