# SBOM Generation for ML Dependencies with Syft and CycloneDX

## What is an SBOM?
Software Bill of Materials - a complete inventory of all components in a software artifact.
For AI/ML: extends to include training data, pre-trained models, and ML frameworks.

## Why SBOM for AI?
- Executive Order 14028 (Improving Nation's Cybersecurity) requires SBOM
- ML packages (PyTorch, TensorFlow) have CVEs that can impact model security
- Log4Shell showed any dependency can be a critical vulnerability
- AI-BOM extends SBOM to capture training data lineage

## Syft - Generate SBOM

### Installation
```bash
# Install Syft
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Verify
syft version
```

### Generate SBOM for ML Container
```bash
# Generate SBOM for Docker image
syft 123456789.dkr.ecr.us-east-1.amazonaws.com/ml-models:interos-risk-v2.0 \
  -o cyclonedx-json=sbom-container.json

# Generate SBOM for Python project directory
syft dir:/app -o cyclonedx-json=sbom-app.json

# Generate SBOM for requirements.txt
syft /app/requirements.txt -o spdx-json=sbom-requirements.json

# Multiple output formats
syft dir:/app \
  -o cyclonedx-json=sbom.json \
  -o table  # also print to stdout
```

### Example SBOM Output (CycloneDX Format)
```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:abc123",
  "version": 1,
  "metadata": {
    "timestamp": "2024-01-15T10:30:00Z",
    "component": {
      "type": "container",
      "name": "interos-risk-model",
      "version": "2.0.0"
    }
  },
  "components": [
    {
      "type": "library",
      "name": "torch",
      "version": "2.1.0",
      "purl": "pkg:pypi/torch@2.1.0",
      "hashes": [
        {
          "alg": "SHA-256",
          "content": "abc123def456..."
        }
      ],
      "licenses": [{"license": {"id": "BSD-3-Clause"}}]
    },
    {
      "type": "library",
      "name": "scikit-learn",
      "version": "1.3.0",
      "purl": "pkg:pypi/scikit-learn@1.3.0"
    }
  ]
}
```

## Grype - Scan SBOM for Vulnerabilities
```bash
# Install Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Scan SBOM for vulnerabilities
grype sbom:./sbom.json

# Output:
# NAME          INSTALLED  FIXED-IN  TYPE    VULNERABILITY  SEVERITY
# torch         2.1.0      2.1.1     python  CVE-2024-XXXX  HIGH
# requests      2.28.0     2.31.0    python  CVE-2023-32681 MEDIUM

# Fail CI if HIGH or CRITICAL vulnerabilities found
grype sbom:./sbom.json --fail-on high
```

## AI-BOM: Extending SBOM for ML Components

### Components to Include
```python
from dataclasses import dataclass, field
from typing import List, Optional
from datetime import datetime
import json
import hashlib

@dataclass
class AIBillOfMaterials:
    model_name: str
    model_version: str
    created_at: str
    
    # Software dependencies (traditional SBOM)
    python_packages: List[dict] = field(default_factory=list)
    system_libraries: List[dict] = field(default_factory=list)
    container_base_image: str = ''
    
    # ML-specific components
    training_datasets: List[dict] = field(default_factory=list)
    pre_trained_models: List[dict] = field(default_factory=list)
    model_architecture: dict = field(default_factory=dict)
    training_framework: str = ''
    
    # Provenance
    training_job_id: str = ''
    training_data_hash: str = ''
    model_weights_hash: str = ''
    code_commit_hash: str = ''
    
    def to_cyclonedx(self) -> dict:
        components = []
        
        # Python packages
        for pkg in self.python_packages:
            components.append({
                'type': 'library',
                'name': pkg['name'],
                'version': pkg['version'],
                'purl': f'pkg:pypi/{pkg["name"]}@{pkg["version"]}'
            })
        
        # Training datasets (AI-BOM extension)
        for dataset in self.training_datasets:
            components.append({
                'type': 'data',
                'name': dataset['name'],
                'version': dataset['version'],
                'hashes': [{'alg': 'SHA-256', 'content': dataset['hash']}],
                'properties': [
                    {'name': 'dataType', 'value': dataset.get('type', 'training')},
                    {'name': 'recordCount', 'value': str(dataset.get('records', 0))},
                    {'name': 'source', 'value': dataset.get('source', 'internal')}
                ]
            })
        
        # Pre-trained model weights
        for pretrained in self.pre_trained_models:
            components.append({
                'type': 'machine-learning-model',
                'name': pretrained['name'],
                'version': pretrained['version'],
                'externalReferences': [{
                    'type': 'website',
                    'url': pretrained.get('source_url', '')
                }],
                'hashes': [{'alg': 'SHA-256', 'content': pretrained['hash']}]
            })
        
        return {
            'bomFormat': 'CycloneDX',
            'specVersion': '1.4',
            'version': 1,
            'metadata': {
                'timestamp': self.created_at,
                'component': {
                    'type': 'machine-learning-model',
                    'name': self.model_name,
                    'version': self.model_version
                },
                'properties': [
                    {'name': 'trainingJobId', 'value': self.training_job_id},
                    {'name': 'trainingDataHash', 'value': self.training_data_hash},
                    {'name': 'modelWeightsHash', 'value': self.model_weights_hash},
                    {'name': 'codeCommitHash', 'value': self.code_commit_hash}
                ]
            },
            'components': components
        }

# Generate AI-BOM during training job completion
def generate_model_aibom(training_job_name):
    import boto3
    sm = boto3.client('sagemaker')
    job = sm.describe_training_job(TrainingJobName=training_job_name)
    
    aibom = AIBillOfMaterials(
        model_name='interos-supply-chain-risk',
        model_version='2.0',
        created_at=datetime.utcnow().isoformat() + 'Z',
        training_job_id=training_job_name,
        code_commit_hash=job['Environment'].get('GIT_COMMIT', ''),
        training_data_hash=job['Environment'].get('DATA_HASH', '')
    )
    
    # Get Python packages from job environment
    aibom.python_packages = get_installed_packages()
    aibom.training_datasets = get_training_data_manifest(job)
    
    # Save SBOM to S3
    s3 = boto3.client('s3')
    s3.put_object(
        Bucket='interos-ml-governance',
        Key=f'sboms/{training_job_name}/aibom.json',
        Body=json.dumps(aibom.to_cyclonedx(), indent=2)
    )
    return aibom
```

## CI/CD SBOM Pipeline
```yaml
# .github/workflows/ml-security.yml
name: ML Security Pipeline

on:
  push:
    branches: [main]
    paths:
      - 'ml/**'
      - 'requirements*.txt'

jobs:
  sbom-and-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Generate SBOM
      uses: anchore/sbom-action@v0
      with:
        path: .
        format: cyclonedx-json
        artifact-name: sbom.json
    
    - name: Scan SBOM for Vulnerabilities
      uses: anchore/scan-action@v3
      with:
        sbom: sbom.json
        fail-build: true
        severity-cutoff: high
    
    - name: Upload SBOM to S3
      run: |
        aws s3 cp sbom.json s3://interos-ml-governance/sboms/$GITHUB_SHA/sbom.json
```

## Pidgin Summary
SBOM be like say you get complete ingredient list for your AI:
- Every Python library wey dey inside (like food ingredient)
- Every training dataset wey you use
- Every pre-trained model wey you borrow
- Grype scan the list and check if any ingredient get problem (CVE)
- Government require this list for compliance
