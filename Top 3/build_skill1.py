import os

def w(path, content):
    d = os.path.dirname(path)
    if d:
        os.makedirs(d, exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f'  [CREATED] {path}')

# SKILL 1 - OVERVIEW
w('01-Skill-1-AI-ML-Security-Engineering/docs/00-SKILL-OVERVIEW.md', '''
# Skill 1: AI/ML Security Engineering
## Securing AI/ML Workloads on AWS

### What This Skill Covers
This skill trains you to secure AI/ML systems end-to-end on AWS - from protecting
training data, securing model registries, hardening inference infrastructure, to
monitoring AI workloads in production.

### Why It Matters for Interos
Interos runs AI/ML models that analyze global supply chain risk. These models:
- Process sensitive supplier data (potential espionage targets)
- Make business-critical decisions (must be tamper-proof)
- Run on AWS infrastructure (needs cloud-native security)
- Are targets for model poisoning and extraction attacks

### Core Technologies
| Technology | Purpose | AWS Service |
|-----------|---------|-------------|
| S3 Object Lock | Immutable training data storage | Amazon S3 |
| SageMaker | Model training & deployment | Amazon SageMaker |
| cosign | Cryptographic model signing | ECR + Lambda |
| in-toto | Supply chain attestations | CodePipeline |
| KMS | Encryption key management | AWS KMS |
| EKS | Container orchestration | Amazon EKS |
| VPC | Network isolation | Amazon VPC |

### Learning Path
1. Day 1-2: S3 Object Lock & Training Data Immutability
2. Day 3-4: SageMaker Security Hardening
3. Day 5-6: Model Registry & Cryptographic Signing
4. Day 7-8: EKS Security for ML Inference
5. Day 9-10: End-to-End Lab Simulation

### Pidgin Summary
We dey protect AI like bank dey protect money:
- Training data = your account balance (nobody fit change am)
- Model = your ATM card (must be authenticated)
- Inference server = bank vault (only authorized people enter)
''')

