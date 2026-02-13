# AI Security SBOM Pipeline

## Overview

> **Mentor Note**: Think of a Software Bill of Materials (SBOM) like an ingredient list on food packaging. Just as you check ingredients for allergens, an SBOM lets you check your software for known security vulnerabilities. This project automates that entire process and adds AI-powered prioritization to focus on what matters most.

This project implements an automated pipeline that generates, analyzes, and monitors Software Bills of Materials (SBOMs) for containerized applications, enhanced with AI-powered vulnerability prioritization. It integrates with CI/CD workflows to ensure every deployment is scanned and cataloged.

### Why This Matters

Modern applications depend on hundreds of open-source libraries. A single vulnerable dependency can compromise entire organizations. AI-enhanced SBOM analysis goes beyond traditional scanning by:

- Predicting which vulnerabilities are most likely to be exploited
- Identifying unusual dependency patterns that suggest supply chain attacks
- Prioritizing remediation based on actual runtime exposure
- Correlating findings across your entire application portfolio

---

## Architecture

```
+------------------+     +----------------+     +------------------+
|   Source Code    |---->|  CI/CD Pipeline |---->|  SBOM Generator  |
|   Repository     |     |  (GitHub Actions)|    |  (Syft/Trivy)    |
+------------------+     +----------------+     +------------------+
                                                         |
                                                         v
+------------------+     +----------------+     +------------------+
|  AI Prioritizer  |<----|  Vulnerability  |<----|  SBOM Storage    |
|  (ML Model)      |     |  Enrichment    |     |  (S3/DynamoDB)   |
+------------------+     +----------------+     +------------------+
         |
         v
+------------------+
|  Alert/Report    |
|  Dashboard       |
+------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| SBOM Generator | Syft + Trivy | Produce CycloneDX/SPDX format SBOMs |
| Storage Layer | S3 + DynamoDB | Version and store SBOMs with metadata |
| Vulnerability Enrichment | OSV.dev + NVD API | Map components to known CVEs |
| AI Prioritizer | Python ML (scikit-learn) | Score and rank vulnerabilities |
| Policy Engine | Open Policy Agent | Enforce organizational standards |
| Dashboard | CloudWatch + SNS | Visualize and alert on findings |

---

## Core Concepts

### SBOM Formats

| Format | Maintained By | Best For |
|--------|--------------|----------|
| **CycloneDX** | OWASP | Security vulnerability workflows |
| **SPDX** | Linux Foundation | License compliance (ISO standard) |

### AI-Enhanced Prioritization Features

1. **Reachability Analysis** - Is the vulnerable function actually called in your code?
2. **Exploit Maturity** - Are there known exploits in the wild?
3. **Environmental Context** - Is this service internet-facing?
4. **Historical Patterns** - How quickly do similar CVEs get weaponized?

---

## Implementation Guide

### Step 1: CI/CD SBOM Generation

```yaml
name: SBOM Security Pipeline
on:
  push:
    branches: [main]

jobs:
  generate-sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate SBOM with Syft
        uses: anchore/sbom-action@v0
        with:
          format: cyclonedx-json
          output-file: sbom.cdx.json
      
      - name: Scan for vulnerabilities
        uses: aquasecurity/trivy-action@master
        with:
          input: sbom.cdx.json
          format: json
          output: vuln-report.json
      
      - name: Upload to S3
        run: |
          aws s3 cp sbom.cdx.json s3://sbom-store/${{ github.sha }}/
          aws s3 cp vuln-report.json s3://sbom-store/${{ github.sha }}/
```

### Step 2: Vulnerability Enrichment

```python
import requests
import json

def enrich_vulnerabilities(vuln_report_path):
    """Enrich vulnerability data from multiple sources."""
    with open(vuln_report_path) as f:
        vulns = json.load(f)
    
    enriched = []
    for result in vulns.get("Results", []):
        for v in result.get("Vulnerabilities", []):
            cve_id = v.get("VulnerabilityID")
            osv_resp = requests.post(
                "https://api.osv.dev/v1/vulns",
                json={"id": cve_id}
            )
            enriched.append({
                "cve": cve_id,
                "severity": v.get("Severity"),
                "cvss_score": v.get("CVSS", {}).get("nvd", {}).get("V3Score"),
                "package": v.get("PkgName"),
                "fixed_version": v.get("FixedVersion"),
                "osv_details": osv_resp.json() if osv_resp.ok else None
            })
    return enriched
```

### Step 3: ML Prioritization Model

```python
from sklearn.ensemble import GradientBoostingClassifier
import numpy as np

class VulnPrioritizer:
    def __init__(self):
        self.model = GradientBoostingClassifier(
            n_estimators=200, max_depth=5, learning_rate=0.1
        )
    
    def predict_priority(self, vulns):
        scored = []
        for v in vulns:
            features = np.array([
                v["cvss_score"] or 0,
                1 if v.get("exploit_available") else 0,
                self._days_since_disclosure(v),
                self._package_popularity(v["package"]),
                1 if v["fixed_version"] else 0
            ]).reshape(1, -1)
            risk = self.model.predict_proba(features)[0][1]
            v["ai_risk_score"] = round(risk, 3)
            scored.append(v)
        return sorted(scored, key=lambda x: x["ai_risk_score"], reverse=True)
```

---

## Deployment

### Prerequisites

- AWS Account with S3, DynamoDB, Lambda
- GitHub Actions enabled
- Python 3.11+

### Quick Start

```bash
# Generate SBOM locally
syft dir:. -o cyclonedx-json > sbom.json

# Scan for vulnerabilities
trivy sbom sbom.json --format json -o vulns.json

# Run AI prioritization
python prioritizer.py --input vulns.json --output prioritized.json
```

---

## Quick Reference

```bash
# Generate SBOM from container image
syft alpine:latest -o cyclonedx-json

# Scan SBOM for vulnerabilities
trivy sbom sbom.cdx.json

# Query OSV API
curl -X POST https://api.osv.dev/v1/vulns -d "{"id":"CVE-2021-44228"}"
```

### Links
- [CycloneDX Specification](https://cyclonedx.org/specification/overview/)
- [SPDX Specification](https://spdx.dev/specifications/)
- [NTIA SBOM Guidance](https://www.ntia.gov/sbom)
- [OSV.dev](https://osv.dev/)
