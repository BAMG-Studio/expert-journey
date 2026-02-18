# 3. The Front Door (The "Where" & "What")
## Presentation Layer / Client-Side

---

## 3.1 Overview

The presentation layer provides the human-computer interface for the SIEM pipeline. Unlike traditional web applications, this enterprise security system primarily uses:

1. **OpenSearch Dashboards** - Primary visualization and search interface
2. **AWS Console** - Infrastructure management
3. **CLI Tools** - Terraform, AWS CLI for automation
4. **API Endpoints** - Programmatic access for integrations

---

## 3.2 OpenSearch Dashboards (Primary UI)

### Access URL
```
https://{opensearch-endpoint}/_dashboards
```

### Dashboard Catalog

| Dashboard Name | Purpose | Primary User |
|----------------|---------|---------------|
| **Security Overview** | Real-time threat landscape | SOC Analysts |
| **Compliance Status** | NIST 800-53 control evidence | Security Engineers |
| **Executive Summary** | KPIs and risk metrics | CISO |
| **Threat Hunting** | Advanced query interface | Threat Hunters |
| **Incident Timeline** | Event correlation view | Incident Responders |

### Sample Dashboard Layout: Security Overview

```
+----------------------------------------------------------+
| SIEM Security Overview                    [Time: Last 24h]|
+----------------------------------------------------------+
| [Critical Alerts: 3]  [High: 12]  [Medium: 45]  [Low: 234]|
+----------------------------------------------------------+
|                                                           |
|  +------------------+  +--------------------------------+ |
|  | Top Threat Types |  | Event Volume (24h)             | |
|  |                  |  |     ____                       | |
|  | Recon: 45%       |  |    /    \___                   | |
|  | Exfil: 30%       |  |   /         \___              | |
|  | Creds: 25%       |  |  /              \             | |
|  +------------------+  +--------------------------------+ |
|                                                           |
|  +------------------------------------------------------+ |
|  | Recent Critical Events                               | |
|  |------------------------------------------------------| |
|  | 14:32 | GuardDuty | Unauthorized API from TOR exit   | |
|  | 14:28 | CloudTrail| Root account console login       | |
|  | 14:15 | Macie     | PII detected in public S3       | |
|  +------------------------------------------------------+ |
+----------------------------------------------------------+
```

---

## 3.3 Authentication & Authorization

### Authentication Flow

```
[User] --> [Corporate IdP] --> [SAML] --> [OpenSearch] --> [Dashboard]
              (Okta/Azure AD)
```

### Role-Based Access Control (RBAC)

| Role | Permissions | Users |
|------|-------------|-------|
| `siem_admin` | Full access, manage users | 2 |
| `soc_analyst` | Search, create alerts, view dashboards | 12 |
| `compliance_ro` | Read-only compliance dashboards | 5 |
| `executive_ro` | Read-only executive summary | 3 |
| `auditor` | Read-only audit logs (time-limited) | External |

---

## 3.4 API Endpoints

### OpenSearch REST API

```bash
# Search security logs
GET https://{endpoint}/security-logs-*/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "severity": "CRITICAL" }},
        { "range": { "@timestamp": { "gte": "now-1h" }}}
      ]
    }
  }
}

# Get compliance report
GET https://{endpoint}/_plugins/_reports/compliance-summary
```

---

*Document Version: 1.0 | Author: Peter Kolawole | Last Updated: February 2026*
