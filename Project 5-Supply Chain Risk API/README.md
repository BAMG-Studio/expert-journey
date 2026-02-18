# Supply Chain Risk API

**A real-time software supply chain risk assessment API that analyzes dependencies, detects vulnerabilities, evaluates vendor risk posture, and provides continuous threat intelligence for software bill of materials (SBOM) across enterprise portfolios.**

## Architecture Overview

This project delivers a RESTful API and event-driven pipeline that ingests software dependency data, cross-references multiple vulnerability databases, applies risk scoring algorithms, and provides actionable intelligence for supply chain security decisions. It supports integration with CI/CD pipelines, procurement workflows, and executive risk dashboards.

### Core Components

- **Risk Scoring Engine** - Multi-factor risk scoring using CVSS, EPSS, dependency depth, maintainer reputation, and license compliance
- **Vulnerability Aggregator** - Real-time ingestion from NVD, OSV, GitHub Advisory, Snyk, and proprietary threat feeds
- **Dependency Graph Analyzer** - Transitive dependency resolution and attack surface mapping across package ecosystems
- **Vendor Risk Profiler** - Third-party vendor security posture assessment with continuous monitoring
- **License Compliance Engine** - Automated license compatibility checking and policy enforcement
- **Threat Intelligence Feed** - Curated supply chain threat intelligence with IOC correlation
- **Alert & Notification System** - Real-time alerting for new CVEs affecting tracked dependencies

### Technology Stack

| Component | Technology |
|-----------|------------|
| API Framework | FastAPI, Python 3.11 |
| Database | PostgreSQL 15, Redis (caching) |
| Message Queue | Apache Kafka, SQS |
| Graph Database | Neo4j (dependency graphs) |
| Vulnerability Sources | NVD, OSV, GitHub Advisory, Snyk API |
| SBOM Formats | CycloneDX, SPDX, SWID |
| CI/CD | GitHub Actions |
| Infrastructure | AWS ECS Fargate, Lambda |
| Monitoring | Prometheus, Grafana, CloudWatch |
| Documentation | OpenAPI 3.1, Redoc |

## Risk Scoring Model

| Factor | Weight | Data Source | Update Frequency |
|--------|--------|-------------|------------------|
| CVSS Score | 25% | NVD, vendor advisories | Real-time |
| EPSS Probability | 20% | FIRST EPSS | Daily |
| Dependency Depth | 15% | Package manifests | Per scan |
| Maintainer Activity | 10% | GitHub/GitLab APIs | Weekly |
| License Risk | 10% | SPDX database | Per scan |
| Known Exploits | 15% | CISA KEV, ExploitDB | Real-time |
| Vendor Posture | 5% | SecurityScorecard, BitSight | Monthly |

## Prerequisites

- Python >= 3.11
- Docker >= 24.0
- PostgreSQL >= 15
- Redis >= 7.0
- Neo4j >= 5.0
- Apache Kafka (or AWS SQS)
- NVD API key

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 5-Supply Chain Risk API"

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your API keys and database credentials

# Start infrastructure
docker-compose up -d
```

### 2. Initialize Database and Feeds

```bash
# Run database migrations
python manage.py db upgrade

# Seed vulnerability database (initial load ~30 min)
python feeds/seed_nvd.py --year-start 2020
python feeds/seed_osv.py --ecosystems pypi,npm,maven

# Start feed ingestion workers
python feeds/worker.py --daemon
```

### 3. Analyze a Project

```bash
# Start the API server
uvicorn api.main:app --host 0.0.0.0 --port 8000

# Submit an SBOM for analysis
curl -X POST http://localhost:8000/api/v1/analyze \
  -H "Content-Type: application/json" \
  -d '{"sbom_url": "https://example.com/sbom.json", "format": "cyclonedx"}'

# Get risk report
curl http://localhost:8000/api/v1/reports/{analysis_id}
```

## Project Structure

```
Project 5-Supply Chain Risk API/
|-- api/
|   |-- main.py                  # FastAPI application entry
|   |-- routers/
|   |   |-- analyze.py            # SBOM analysis endpoints
|   |   |-- reports.py            # Risk report endpoints
|   |   |-- vendors.py            # Vendor risk endpoints
|   |   |-- alerts.py             # Alert management endpoints
|   |-- middleware/               # Auth, rate limiting, logging
|   |-- schemas/                  # Pydantic request/response models
|-- risk_engine/
|   |-- scorer.py                 # Multi-factor risk scoring
|   |-- cvss_calculator.py        # CVSS v3.1/v4.0 calculator
|   |-- epss_client.py            # EPSS probability client
|   |-- dependency_analyzer.py    # Transitive dependency resolver
|-- feeds/
|   |-- nvd_ingester.py           # NVD feed ingestion
|   |-- osv_ingester.py           # OSV database ingestion
|   |-- github_advisory.py        # GitHub Advisory ingestion
|   |-- worker.py                 # Feed ingestion worker
|   |-- seed_nvd.py               # Initial NVD data seeding
|-- vendor_risk/
|   |-- profiler.py               # Vendor risk assessment
|   |-- scorecard_client.py       # SecurityScorecard integration
|   |-- continuous_monitor.py     # Ongoing vendor monitoring
|-- license_engine/
|   |-- checker.py                # License compatibility checker
|   |-- policies/                 # License policy definitions
|-- graph/
|   |-- dependency_graph.py       # Neo4j dependency graph manager
|   |-- attack_surface.py         # Attack surface mapper
|-- notifications/
|   |-- alerter.py                # Alert dispatch engine
|   |-- channels/                 # Slack, email, PagerDuty, webhook
|-- tests/
|   |-- unit/                     # Unit tests
|   |-- integration/              # Integration tests
|   |-- fixtures/                 # Test SBOM fixtures
|-- .github/
|   |-- workflows/                # CI/CD pipelines
|-- docker-compose.yml
|-- requirements.txt
|-- README.md
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/v1/analyze | Submit SBOM for risk analysis |
| GET | /api/v1/reports/{id} | Retrieve analysis report |
| GET | /api/v1/vulnerabilities | Search vulnerability database |
| POST | /api/v1/vendors/assess | Assess vendor risk posture |
| GET | /api/v1/alerts | List active security alerts |
| POST | /api/v1/sbom/upload | Upload SBOM (CycloneDX/SPDX) |
| GET | /api/v1/graph/{package} | Get dependency graph |
| GET | /api/v1/licenses/check | Check license compatibility |
| GET | /api/v1/metrics/portfolio | Portfolio-wide risk metrics |

## CI/CD Integration

```yaml
# Example GitHub Actions integration
- name: Supply Chain Risk Check
  run: |
    curl -X POST $API_URL/api/v1/analyze \
      -H "Authorization: Bearer $API_TOKEN" \
      -d '{"sbom_path": "./sbom.json", "threshold": "high"}'
```

## Cost Estimates

| Environment | Monthly Cost |
|-------------|-------------|
| Local Development | $0 (Docker) |
| Dev/Staging | ~$150-400 |
| Production | ~$800-2,500 |

## License

MIT License
