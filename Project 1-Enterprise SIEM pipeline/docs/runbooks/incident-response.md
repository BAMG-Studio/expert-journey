# Incident Response Runbook

## Severity Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| P1 - Critical | Active breach, data exfiltration | < 15 min |
| P2 - High | Suspicious activity, potential threat | < 1 hour |
| P3 - Medium | Policy violation, anomaly detected | < 4 hours |
| P4 - Low | Informational, audit finding | < 24 hours |

## P1 - Critical Incident Response

### Step 1: Triage (0-5 minutes)
```bash
# Check SIEM dashboard for active alerts
open $(terraform output -raw siem_dashboard_url)

# Query recent critical findings
aws guardduty list-findings --detector-id $DETECTOR_ID   --finding-criteria '{"Criterion":{"severity":{"Gte":7}}}'
```

### Step 2: Contain (5-15 minutes)
```bash
# Isolate compromised instance (if EC2)
aws ec2 modify-instance-attribute --instance-id i-xxx   --groups sg-isolated-security-group

# Revoke compromised IAM credentials
aws iam update-access-key --user-name compromised-user   --access-key-id AKIAXXXXXX --status Inactive

# Block suspicious IP in WAF/Security Group
aws ec2 revoke-security-group-ingress --group-id sg-xxx   --protocol all --cidr $SUSPICIOUS_IP/32
```

### Step 3: Investigate
```bash
# Export CloudTrail logs for forensics
aws s3 cp s3://enterprise-siem-logs/cloudtrail/ ./forensics/   --recursive --exclude "*" --include "*2026-02-16*"

# Search OpenSearch for related events
curl -X GET "$OPENSEARCH_ENDPOINT/security-events/_search"   -H "Content-Type: application/json"   -d '{"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"now-1h"}}}]}}}'
```

### Step 4: Eradicate & Recover
- Remove malware/backdoors
- Rotate all affected credentials
- Patch vulnerabilities
- Restore from clean backups

### Step 5: Document & Learn
- Complete incident report
- Update detection rules
- Conduct post-mortem
