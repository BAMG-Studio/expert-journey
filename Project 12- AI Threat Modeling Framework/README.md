# AI Threat Modeling Framework

**An AI-powered threat modeling platform that automatically identifies attack surfaces, generates threat models using STRIDE/DREAD/PASTA methodologies, maps mitigations to security controls, and continuously updates threat assessments as architecture evolves.**

## Architecture Overview

This project delivers an intelligent threat modeling system that combines traditional threat modeling frameworks with AI/ML capabilities. It ingests architecture diagrams, infrastructure-as-code, and API specifications to automatically generate comprehensive threat models, recommend prioritized mitigations, and maintain living threat documentation that evolves with the system.

### Core Components

- **Architecture Analyzer** - Parses Terraform, CloudFormation, Kubernetes manifests, and architecture diagrams to build system models
- **AI Threat Generator** - LLM-powered threat identification using STRIDE, DREAD, PASTA, and MITRE ATT&CK frameworks
- **Attack Tree Builder** - Automated attack tree generation with probability scoring and kill chain mapping
- **Mitigation Recommender** - AI-driven security control recommendations mapped to NIST 800-53 and CIS Controls
- **Data Flow Analyzer** - Automated data flow diagram (DFD) generation with trust boundary identification
- **Risk Scorer** - Quantitative risk scoring combining threat likelihood, impact, and current control effectiveness
- **Continuous Threat Monitor** - Architecture change detection with automatic threat model updates

### Technology Stack

| Component | Technology |
|-----------|------------|
| AI/ML Engine | OpenAI GPT-4, Claude, LangChain, local Llama models |
| Architecture Parsing | HCL parser, CloudFormation parser, K8s client |
| Diagram Analysis | Computer vision (OpenCV), diagram-as-code parsing |
| Threat Frameworks | STRIDE, DREAD, PASTA, MITRE ATT&CK v14 |
| Knowledge Base | Neo4j (threat graph), PostgreSQL, Elasticsearch |
| API | FastAPI, GraphQL |
| Visualization | React, D3.js, Mermaid (diagram rendering) |
| IaC Integration | Terraform, CloudFormation, Pulumi, CDK |
| CI/CD | GitHub Actions |
| Export Formats | PDF, HTML, Markdown, SARIF, JSON |

## Threat Modeling Methodologies

| Methodology | Use Case | AI Enhancement | Output |
|------------|----------|---------------|--------|
| STRIDE | Per-component threat ID | Auto-categorization of threats | Threat catalog per component |
| DREAD | Risk prioritization | Automated scoring with historical data | Prioritized risk matrix |
| PASTA | Business-aligned modeling | Attack simulation and likelihood | Attack trees with business impact |
| MITRE ATT&CK | Adversary technique mapping | TTP correlation from threat intel | Kill chain coverage analysis |
| LINDDUN | Privacy threat modeling | PII flow detection and classification | Privacy impact assessment |
| Attack Trees | Visual attack modeling | Auto-generated with probability | Interactive attack tree diagrams |

## Prerequisites

- Python >= 3.11
- Docker >= 24.0
- Neo4j >= 5.0
- PostgreSQL >= 15
- OpenAI API key (or local LLM setup)
- Terraform (for IaC parsing)

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 12- AI Threat Modeling Framework"

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Set OPENAI_API_KEY, Neo4j credentials, database settings

# Start infrastructure
docker-compose up -d

# Initialize threat knowledge base
python knowledge_base/init.py --load-mitre --load-cwe --load-capec
```

### 2. Generate Threat Model from IaC

```bash
# Analyze Terraform infrastructure
python analyzer/scan.py --source ../"Project 1-Enterprise SIEM pipeline/terraform" --type terraform

# Generate AI-powered threat model
python threat_generator/generate.py \
  --architecture-id latest \
  --methodologies stride,dread,attack-trees \
  --ai-enhanced

# Generate threat model report
python reports/generate.py --model-id latest --format html --output reports/
```

### 3. Continuous Threat Monitoring

```bash
# Start architecture change monitor
python monitor/watch.py --repos ./config/watched-repos.yml --interval 1h

# Start API server
uvicorn api.main:app --host 0.0.0.0 --port 8000
```

## Project Structure

```
Project 12- AI Threat Modeling Framework/
|-- analyzer/
|   |-- scan.py                    # Architecture scanner orchestrator
|   |-- parsers/
|   |   |-- terraform_parser.py     # Terraform HCL parser
|   |   |-- cloudformation_parser.py # CloudFormation parser
|   |   |-- kubernetes_parser.py    # K8s manifest parser
|   |   |-- openapi_parser.py       # OpenAPI/Swagger parser
|   |   |-- diagram_parser.py       # Architecture diagram analyzer
|   |-- model_builder.py           # System model constructor
|   |-- data_flow.py               # Data flow diagram generator
|-- threat_generator/
|   |-- generate.py                # Main threat generation engine
|   |-- stride.py                  # STRIDE methodology engine
|   |-- dread.py                   # DREAD scoring engine
|   |-- pasta.py                   # PASTA methodology engine
|   |-- attack_trees.py            # Attack tree generator
|   |-- ai_engine.py               # LLM-powered threat analysis
|-- knowledge_base/
|   |-- init.py                    # Knowledge base initializer
|   |-- mitre_attack/              # MITRE ATT&CK integration
|   |-- cwe_database/              # CWE weakness catalog
|   |-- capec_database/            # CAPEC attack patterns
|   |-- threat_intel/              # Threat intelligence feeds
|-- mitigation/
|   |-- recommender.py             # AI mitigation recommender
|   |-- control_mapper.py          # NIST/CIS control mapping
|   |-- effectiveness.py           # Control effectiveness scorer
|-- risk_scoring/
|   |-- scorer.py                  # Quantitative risk scorer
|   |-- impact_analyzer.py         # Business impact analysis
|   |-- likelihood.py              # Threat likelihood estimator
|-- monitor/
|   |-- watch.py                   # Architecture change monitor
|   |-- diff_analyzer.py           # Change impact analyzer
|   |-- auto_update.py             # Threat model auto-updater
|-- reports/
|   |-- generate.py                # Report generation engine
|   |-- templates/                 # Report templates (HTML, PDF, MD)
|   |-- visualizations/            # D3.js threat visualizations
|-- api/
|   |-- main.py                    # FastAPI application
|   |-- routers/                   # API route handlers
|   |-- schemas/                   # Request/response models
|-- dashboard/
|   |-- src/                       # React frontend
|   |-- components/                # Threat model UI components
|-- tests/
|   |-- unit/                      # Unit tests
|   |-- integration/               # Integration tests
|   |-- model_accuracy/            # AI model accuracy tests
|-- .github/
|   |-- workflows/                 # CI/CD pipeline definitions
|-- docker-compose.yml
|-- requirements.txt
|-- README.md
```

## Threat Modeling Workflow

1. **Ingest** - Parse architecture artifacts (IaC, diagrams, API specs)
2. **Model** - Build system model with components, data flows, and trust boundaries
3. **Analyze** - AI identifies threats using STRIDE/DREAD/PASTA methodologies
4. **Map** - Correlate threats to MITRE ATT&CK techniques and CWE weaknesses
5. **Score** - Quantitative risk scoring with business impact analysis
6. **Recommend** - AI generates prioritized mitigation recommendations
7. **Report** - Generate comprehensive threat model documentation
8. **Monitor** - Continuously watch for architecture changes and update model

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/v1/analyze | Submit architecture for analysis |
| GET | /api/v1/models/{id} | Get threat model |
| GET | /api/v1/models/{id}/threats | List identified threats |
| GET | /api/v1/models/{id}/mitigations | Get mitigation recommendations |
| GET | /api/v1/models/{id}/attack-trees | Get attack tree visualizations |
| GET | /api/v1/models/{id}/report | Generate threat model report |
| POST | /api/v1/models/{id}/rescan | Trigger threat model rescan |
| GET | /api/v1/knowledge/mitre | Query MITRE ATT&CK knowledge base |

## Cost Estimates

| Environment | Monthly Cost |
|-------------|-------------|
| Local Development | ~$0-30 (LLM API calls) |
| Dev/Staging | ~$100-400 |
| Production | ~$500-2,000 |

## License

MIT License
