# MLOps Model Registry

## Overview

> **Mentor Note**: A model registry is like a version-controlled library for machine learning models. Just as Git tracks code changes, a model registry tracks model versions, their training data, performance metrics, and deployment status - ensuring you always know which model is running where and why.

This project implements a production-grade MLOps model registry using AWS SageMaker Model Registry with custom extensions for model governance, A/B testing orchestration, and automated model promotion pipelines. It provides full lineage tracking from training data to production deployment.

### Why This Matters

- Organizations deploy dozens of ML models, each requiring version control
- Regulatory requirements demand model explainability and audit trails
- Model performance degrades over time (concept drift) and needs monitoring
- Reproducibility is critical for debugging and compliance

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  Training        |---->|  Model Registry  |---->|  Deployment      |
|  Pipeline        |     |  (SageMaker)     |     |  Pipeline        |
|  (SageMaker Jobs)|     |                  |     |  (Step Functions)|
+------------------+     +------------------+     +------------------+
         |                        |                        |
         v                        v                        v
+------------------+     +------------------+     +------------------+
|  Experiment      |     |  Model Card      |     |  A/B Testing     |
|  Tracking        |     |  (Governance)    |     |  Orchestration   |
|  (MLflow)        |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Model Storage | SageMaker Model Registry | Version and catalog models |
| Experiment Tracking | MLflow | Track training runs and metrics |
| Model Cards | Custom Python | Governance documentation |
| Promotion Pipeline | Step Functions | Automated model promotion |
| A/B Testing | SageMaker Endpoints | Compare model performance |
| Monitoring | CloudWatch + Custom | Detect model drift |

---

## Core Concepts

### Model Lifecycle Stages

| Stage | Description | Gate Criteria |
|-------|-----------|---------------|
| **Development** | Initial training and experimentation | Metrics above baseline |
| **Staging** | Validation on holdout data | Passes bias and fairness checks |
| **Production** | Serving live traffic | Approved by model review board |
| **Archived** | Retired from production | Replacement model deployed |

### Model Governance Requirements

1. **Lineage** - Track data, code, and parameters for every model version
2. **Explainability** - SHAP values or feature importance for all models
3. **Bias Detection** - Fairness metrics across protected attributes
4. **Performance Monitoring** - Real-time accuracy and latency tracking

---

## Implementation Guide

### Step 1: Register Model in SageMaker

```python
import boto3
import sagemaker
from sagemaker.model_metrics import ModelMetrics, MetricsSource

def register_model(model_artifact, metrics, model_package_group):
    """Register a trained model with full metadata."""
    sm = sagemaker.Session()
    
    model_metrics = ModelMetrics(
        model_statistics=MetricsSource(
            s3_uri=metrics["statistics_uri"],
            content_type="application/json"
        ),
        bias=MetricsSource(
            s3_uri=metrics["bias_uri"],
            content_type="application/json"
        ),
        explainability=MetricsSource(
            s3_uri=metrics["explainability_uri"],
            content_type="application/json"
        )
    )
    
    model_package = sm.sagemaker_client.create_model_package(
        ModelPackageGroupName=model_package_group,
        InferenceSpecification={
            "Containers": [{
                "Image": "ACCOUNT.dkr.ecr.REGION.amazonaws.com/model:latest",
                "ModelDataUrl": model_artifact
            }],
            "SupportedContentTypes": ["application/json"],
            "SupportedResponseMIMETypes": ["application/json"]
        },
        ModelMetrics=model_metrics,
        ModelApprovalStatus="PendingManualApproval"
    )
    
    return model_package["ModelPackageArn"]
```

### Step 2: Automated Promotion Pipeline

```python
def promote_model(model_package_arn, target_stage):
    """Promote model through lifecycle stages with validation."""
    sm = boto3.client("sagemaker")
    
    # Validate promotion criteria
    package = sm.describe_model_package(ModelPackageName=model_package_arn)
    metrics = evaluate_model_metrics(package)
    
    if not meets_promotion_criteria(metrics, target_stage):
        raise ValueError(f"Model does not meet {target_stage} criteria")
    
    # Update approval status
    sm.update_model_package(
        ModelPackageArn=model_package_arn,
        ModelApprovalStatus="Approved",
        ApprovalDescription=f"Auto-promoted to {target_stage}"
    )
    
    # Deploy to target environment
    if target_stage == "Production":
        deploy_to_endpoint(model_package_arn, "prod-endpoint")
```

### Step 3: Model Drift Detection

```python
def check_model_drift(endpoint_name, baseline_metrics):
    """Monitor model performance and detect drift."""
    current_metrics = get_endpoint_metrics(endpoint_name)
    
    drift_detected = False
    for metric, baseline in baseline_metrics.items():
        current = current_metrics.get(metric, 0)
        drift_pct = abs(current - baseline) / baseline * 100
        
        if drift_pct > DRIFT_THRESHOLD:
            drift_detected = True
            alert_model_drift(endpoint_name, metric, baseline, current)
    
    return drift_detected
```

---

## Deployment

### Prerequisites

- AWS SageMaker access
- MLflow server (or SageMaker Experiments)
- Python 3.11+ with sagemaker SDK

### Quick Start

```bash
# Create model package group
python create_registry.py --group fraud-detection-models

# Register a trained model
python register_model.py --artifact s3://models/latest/model.tar.gz

# Check model status
aws sagemaker list-model-packages --model-package-group-name fraud-detection-models
```

---

## Quick Reference

| Task | Command |
|------|--------|
| List model groups | `aws sagemaker list-model-package-groups` |
| List model versions | `aws sagemaker list-model-packages --model-package-group <name>` |
| Approve model | `aws sagemaker update-model-package --model-package-arn <arn> --model-approval-status Approved` |
| Describe model | `aws sagemaker describe-model-package --model-package-name <arn>` |

### Links
- [SageMaker Model Registry](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry.html)
- [MLflow Model Registry](https://mlflow.org/docs/latest/model-registry.html)
- [ML Model Governance](https://aws.amazon.com/blogs/machine-learning/)
