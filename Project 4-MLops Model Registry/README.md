# MLOps Model Registry

**A production-grade ML model registry and lifecycle management platform that automates model versioning, validation, deployment, and monitoring across multi-cloud environments with built-in security and governance.**

## Architecture Overview

This project implements a centralized model registry that serves as the single source of truth for all machine learning models across the organization. It integrates with training pipelines, CI/CD systems, and serving infrastructure to provide end-to-end model lifecycle management with automated quality gates, A/B testing, and performance monitoring.

### Core Components

- **Model Registry** - Centralized versioned storage for ML models with metadata, lineage, and artifact management
- **Validation Pipeline** - Automated model quality gates including performance benchmarks, bias detection, and security scanning
- **Deployment Orchestrator** - Multi-target deployment engine supporting SageMaker, Vertex AI, Azure ML, and Kubernetes
- **A/B Test Manager** - Traffic splitting and canary deployment controller with statistical significance testing
- **Monitoring Engine** - Real-time model performance tracking with data drift, concept drift, and prediction quality alerts
- **Governance Dashboard** - Model inventory, approval workflows, and compliance audit trail
- **Feature Store Connector** - Integration with Feast and SageMaker Feature Store for reproducible inference

### Technology Stack

| Component | Technology |
|-----------|------------|
| Model Registry | MLflow, custom Python API |
| Orchestration | Apache Airflow, Prefect |
| Model Serving | SageMaker, TorchServe, TF Serving, Triton |
| Monitoring | Evidently AI, Prometheus, Grafana |
| Feature Store | Feast, SageMaker Feature Store |
| CI/CD | GitHub Actions, Jenkins |
| Storage | S3, GCS, Azure Blob |
| Container | Docker, Kubernetes, EKS |
| Database | PostgreSQL, Redis (caching) |
| API | FastAPI, gRPC |

## Model Lifecycle Stages

| Stage | Automated Gates | Approval Required | SLA |
|-------|----------------|-------------------|-----|
| Development | Unit tests, linting | No | - |
| Staging | Performance benchmarks, bias checks | No | 2hr |
| Canary | A/B test significance, error rate | Yes (ML Lead) | 24hr |
| Production | SLA validation, rollback readiness | Yes (ML Lead + SRE) | 4hr |
| Deprecated | Usage audit, downstream impact | Yes (ML Lead) | 7d |
| Archived | Data retention compliance | No | 30d |

## Prerequisites

- Python >= 3.10
- Docker >= 24.0
- Kubernetes cluster (EKS/GKE/AKS) or local minikube
- AWS/GCP/Azure credentials for model serving
- PostgreSQL >= 14
- Redis >= 7.0

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 4-MLops Model Registry"

# Install dependencies
pip install -r requirements.txt

# Start infrastructure
docker-compose up -d

# Initialize database
python registry/init_db.py --migrate
```

### 2. Register a Model

```bash
# Register a new model
python registry/register.py \
  --name "fraud-detection-v2" \
  --framework pytorch \
  --artifact models/fraud_detector.pt \
  --metrics '{"accuracy": 0.95, "f1": 0.92, "auc": 0.98}' \
  --tags '{"team": "risk", "use_case": "transaction_fraud"}'

# Promote to staging
python registry/promote.py --model fraud-detection-v2 --version 1 --stage staging
```

### 3. Deploy and Monitor

```bash
# Deploy to SageMaker endpoint
python deployment/deploy.py \
  --model fraud-detection-v2 \
  --version 1 \
  --target sagemaker \
  --instance ml.m5.xlarge \
  --canary-split 10

# Start monitoring
python monitoring/monitor.py --model fraud-detection-v2 --alerts enabled
```

## Project Structure

```
Project 4-MLops Model Registry/
|-- registry/
|   |-- api/                     # FastAPI model registry endpoints
|   |-- models.py                # Database models (SQLAlchemy)
|   |-- register.py              # Model registration CLI
|   |-- promote.py               # Stage promotion manager
|   |-- init_db.py               # Database initialization
|   |-- lineage.py               # Model lineage tracker
|-- validation/
|   |-- pipeline.py              # Validation pipeline orchestrator
|   |-- benchmarks/              # Performance benchmark suites
|   |-- bias_detection/          # Fairness and bias checks
|   |-- security_scan/           # Model security scanning
|-- deployment/
|   |-- deploy.py                # Multi-target deployment engine
|   |-- strategies/              # Deployment strategies (canary, blue-green)
|   |-- targets/
|   |   |-- sagemaker.py         # AWS SageMaker deployer
|   |   |-- vertex.py            # GCP Vertex AI deployer
|   |   |-- kubernetes.py        # K8s deployment manager
|-- monitoring/
|   |-- monitor.py               # Real-time monitoring engine
|   |-- drift_detection/         # Data and concept drift detectors
|   |-- dashboards/              # Grafana dashboard configs
|   |-- alerting/                # Alert rules and escalation
|-- ab_testing/
|   |-- manager.py               # A/B test orchestrator
|   |-- analysis.py              # Statistical significance testing
|-- governance/
|   |-- approval_workflow.py     # Model approval workflows
|   |-- audit.py                 # Compliance audit trail
|   |-- inventory.py             # Model inventory management
|-- tests/
|   |-- unit/                    # Unit tests
|   |-- integration/             # Integration tests
|   |-- e2e/                     # End-to-end tests
|-- .github/
|   |-- workflows/               # CI/CD pipeline definitions
|-- docker-compose.yml
|-- requirements.txt
|-- README.md
```

## CI/CD Pipeline

1. **Model Training** - Triggered by data pipeline or manual; outputs model artifacts
2. **Registration** - Auto-registers model with metrics, lineage, and metadata
3. **Validation** - Performance benchmarks, bias checks, and security scan
4. **Staging Deploy** - Shadow deployment for integration testing
5. **Canary Release** - Gradual traffic shift with automated rollback
6. **Production** - Full deployment with monitoring enabled

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /models/register | Register new model version |
| GET | /models/{name}/versions | List model versions |
| PUT | /models/{name}/promote | Promote to next stage |
| GET | /models/{name}/metrics | Get model performance metrics |
| POST | /models/{name}/deploy | Trigger deployment |
| GET | /models/{name}/lineage | Get model lineage graph |
| DELETE | /models/{name}/archive | Archive deprecated model |

## Cost Estimates

| Environment | Monthly Cost |
|-------------|-------------|
| Local Development | $0 (Docker) |
| Dev/Staging | ~$200-500 |
| Production | ~$1,000-3,000 |

## License

MIT License
