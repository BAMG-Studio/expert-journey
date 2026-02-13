# Supply Chain Risk API

## Overview

> **Mentor Note**: Software supply chain security is about knowing and trusting every component in your software, just like food safety tracks ingredients from farm to table. This API provides a centralized service for evaluating the security risk of open-source dependencies before they enter your codebase.

This project implements a RESTful API service that evaluates software supply chain risk by analyzing package metadata, vulnerability history, maintainer reputation, and dependency graphs. It integrates with CI/CD pipelines to automatically gate deployments based on supply chain risk scores.

### Why This Matters

- Supply chain attacks increased 742% from 2019 to 2022
- SolarWinds, Log4Shell, and CodeCov demonstrated catastrophic impact
- Executive Order 14028 mandates supply chain security for federal software
- Organizations need automated risk assessment at scale

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  CI/CD Pipeline  |---->|  API Gateway     |---->|  Risk Engine     |
|  (GitHub Actions)|     |  (REST API)      |     |  (Lambda/ECS)    |
+------------------+     +------------------+     +------------------+
                                                         |
                                  +----------------------+
                                  |          |           |
                                  v          v           v
                          +----------+ +----------+ +----------+
                          | Package  | | Vuln     | | Maintainer|
                          | Metadata | | History  | | Analysis  |
                          +----------+ +----------+ +----------+
                                  |          |           |
                                  v          v           v
                          +----------------------------------+
                          |       Composite Risk Score       |
                          +----------------------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| API Layer | API Gateway + Lambda | RESTful interface for risk queries |
| Risk Engine | Python (FastAPI) | Calculate composite risk scores |
| Package Analysis | Custom crawlers | Gather package metadata |
| Vulnerability DB | DynamoDB + OSV.dev | Track known vulnerabilities |
| Maintainer Analysis | GitHub API | Assess maintainer trustworthiness |
| Dependency Graph | Neo4j / DynamoDB | Map transitive dependencies |

---

## Core Concepts

### Risk Score Components

| Factor | Weight | Description |
|--------|--------|-------------|
| **Vulnerability History** | 30% | Number and severity of past CVEs |
| **Maintainer Trust** | 25% | Account age, activity, 2FA enabled |
| **Dependency Depth** | 20% | Transitive dependency count and risk |
| **Package Popularity** | 15% | Download count, GitHub stars, forks |
| **License Compliance** | 10% | License compatibility and restrictions |

### Risk Levels

| Score | Level | Action |
|-------|-------|--------|
| 0-30 | Low | Auto-approve |
| 31-60 | Medium | Flag for review |
| 61-80 | High | Require approval |
| 81-100 | Critical | Block deployment |

---

## Implementation Guide

### Step 1: FastAPI Risk Engine

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Supply Chain Risk API")

class PackageRequest(BaseModel):
    name: str
    version: str
    ecosystem: str  # npm, pypi, maven

class RiskResponse(BaseModel):
    package: str
    version: str
    risk_score: float
    risk_level: str
    factors: dict
    recommendation: str

@app.post("/api/v1/assess", response_model=RiskResponse)
async def assess_package(request: PackageRequest):
    """Assess supply chain risk for a package."""
    vuln_score = await check_vulnerabilities(request)
    maintainer_score = await analyze_maintainer(request)
    dependency_score = await analyze_dependencies(request)
    popularity_score = await check_popularity(request)
    license_score = await check_license(request)
    
    composite = (
        vuln_score * 0.30 +
        maintainer_score * 0.25 +
        dependency_score * 0.20 +
        popularity_score * 0.15 +
        license_score * 0.10
    )
    
    return RiskResponse(
        package=request.name,
        version=request.version,
        risk_score=round(composite, 2),
        risk_level=get_risk_level(composite),
        factors={
            "vulnerability": vuln_score,
            "maintainer": maintainer_score,
            "dependencies": dependency_score,
            "popularity": popularity_score,
            "license": license_score
        },
        recommendation=get_recommendation(composite)
    )
```

### Step 2: CI/CD Integration

```yaml
name: Supply Chain Check
on: pull_request

jobs:
  risk-assessment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Extract dependencies
        run: pip freeze > requirements.txt
      
      - name: Assess supply chain risk
        run: |
          while IFS= read -r dep; do
            pkg=$(echo $dep | cut -d= -f1)
            ver=$(echo $dep | cut -d= -f3)
            result=$(curl -s -X POST $API_URL/api/v1/assess \
              -H "Content-Type: application/json" \
              -d "{\"name\":\"$pkg\",\"version\":\"$ver\",\"ecosystem\":\"pypi\"}")
            score=$(echo $result | jq '.risk_score')
            if (( $(echo "$score > 80" | bc -l) )); then
              echo "BLOCKED: $pkg@$ver (risk: $score)"
              exit 1
            fi
          done < requirements.txt
```

### Step 3: Vulnerability Analysis

```python
async def check_vulnerabilities(package):
    """Query multiple vulnerability databases."""
    vulns = []
    
    # Query OSV.dev
    osv_resp = await query_osv(package.name, package.version, package.ecosystem)
    vulns.extend(osv_resp)
    
    # Query NVD
    nvd_resp = await query_nvd(package.name)
    vulns.extend(nvd_resp)
    
    # Calculate score based on severity and recency
    if not vulns:
        return 0  # No known vulnerabilities
    
    critical = sum(1 for v in vulns if v["severity"] == "CRITICAL")
    high = sum(1 for v in vulns if v["severity"] == "HIGH")
    
    return min(100, critical * 25 + high * 15 + len(vulns) * 5)
```

---

## Deployment

### Prerequisites

- AWS Account with API Gateway, Lambda, DynamoDB
- Python 3.11+ with FastAPI
- GitHub token for maintainer analysis

### Quick Start

```bash
# Deploy API infrastructure
cd terraform/supply-chain-api
terraform apply

# Test locally
uvicorn main:app --reload

# Test assessment
curl -X POST http://localhost:8000/api/v1/assess \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"requests\",\"version\":\"2.31.0\",\"ecosystem\":\"pypi\"}"
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Assess single package | `curl -X POST /api/v1/assess -d {...}` |
| Batch assessment | `curl -X POST /api/v1/assess/batch -d [...]` |
| Get risk history | `curl /api/v1/history/<package>` |
| Update vuln database | `python sync_vulns.py --source osv,nvd` |

### Links
- [OpenSSF Scorecard](https://github.com/ossf/scorecard)
- [OSV.dev API](https://osv.dev/docs/)
- [SLSA Framework](https://slsa.dev/)
- [Sigstore](https://www.sigstore.dev/)
