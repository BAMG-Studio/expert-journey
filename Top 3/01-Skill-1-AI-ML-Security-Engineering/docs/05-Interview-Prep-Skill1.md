
# Skill 1 Interview Preparation: AI/ML Security Engineering

## Top 10 Interview Questions & Answers

### Q1: How do you protect ML training data from tampering?
**Answer Framework**: Data + Process + Detection

"I use a three-layer approach:
1. **Prevention**: S3 Object Lock in GOVERNANCE mode ensures no one can delete
   or overwrite training data. Combined with KMS encryption, even privileged users
   cannot read data without the key.
2. **Process**: Every dataset upload generates a SHA-256 hash stored in metadata.
   Training jobs verify hash before loading data.
3. **Detection**: AWS Macie continuously scans for anomalous data access patterns.
   CloudTrail alerts on any attempt to modify bucket lock configuration."

### Q2: Explain the difference between model poisoning and data poisoning
**Answer**:
- **Data poisoning**: Attacker corrupts TRAINING DATA before/during training
  - Example: Inject mislabeled supplier risk scores to make high-risk suppliers
    appear safe
  - Defense: S3 Object Lock, data lineage tracking, statistical anomaly detection
- **Model poisoning**: Attacker directly modifies the MODEL WEIGHTS after training
  - Example: Replace production model file with backdoored version
  - Defense: cosign model signing, SageMaker Model Registry approval workflow,
    deployment gates that verify signatures

### Q3: What is IRSA and why use it instead of EC2 instance profiles?
**Answer**:
"IRSA (IAM Roles for Service Accounts) maps Kubernetes service accounts to IAM
roles using OIDC federation. Unlike instance profiles:
- **Granularity**: Each pod gets its own IAM role (not shared per node)
- **Least Privilege**: Inference pods only get S3 read + KMS decrypt
- **Audit Trail**: CloudTrail shows exactly which pod made which API call
- **No Key Management**: No long-lived credentials, automatic rotation

With EC2 instance profiles, if any pod is compromised, the attacker gets
all permissions for that entire node. IRSA limits blast radius to one pod."

### Q4: How does cosign prevent supply chain attacks on ML models?
**Answer**:
"cosign signs ML model artifacts stored in ECR with a private key kept in AWS KMS.
The workflow:
1. After training completes, CI/CD signs the model artifact with cosign
2. Signature is stored in ECR alongside the model
3. Before ANY deployment, a Lambda function verifies the signature
4. If verification fails, deployment is blocked and security team is alerted

This prevents: model replacement by attackers, unauthorized model versions
deploying, models from unverified training pipelines running in production.
Even if an attacker gains S3 write access, they cannot forge a valid cosign
signature without the KMS key."

### Q5: Walk me through securing a SageMaker training job end-to-end
**Answer** (tell as a story):
"Sure. Here's the full secure pipeline:
1. Data scientist commits training code to GitHub
2. CodePipeline triggers, runs security scan (Bandit for Python, SAST)
3. Training job created with EnableNetworkIsolation=True (no internet)
4. Training job runs in private VPC subnet (no NAT gateway)
5. Input data from S3 Object Lock bucket (immutable, encrypted with KMS)
6. Training output goes to separate S3 bucket with KMS encryption
7. CloudTrail logs every API call during training
8. After training, cosign signs the model artifact
9. SageMaker Model Registry receives model with PendingManualApproval status
10. ML security team reviews metrics + attestations, approves
11. Only then does CodePipeline deploy to staging, then production"

### Q6: What AWS services would you use for ML security monitoring?
**Answer**:
| Threat | Detection Service | Response |
|--------|------------------|----------|
| Unauthorized model access | CloudTrail + EventBridge | SNS alert + Lambda quarantine |
| Data exfiltration | Macie + VPC Flow Logs | Automated bucket policy tightening |
| Compromised notebook | GuardDuty ML threat detection | Suspend notebook instance |
| Model drift/poisoning | SageMaker Model Monitor | Rollback to last known good |
| Container escape | Falco on EKS | Terminate pod, alert security |

### Q7: How do you handle the tension between security and ML team productivity?
**Answer**:
"Security must be a developer experience, not a blocker. My approach:
1. **Pre-approved secure templates**: Terraform modules for SageMaker, S3, EKS
   that are pre-configured with security controls baked in
2. **Shift-left**: Security scanning in CI/CD so issues found before deployment
3. **Guardrails not gates**: AWS Service Control Policies prevent insecure configs
   but don't slow down correct workflows
4. **Metrics**: Track mean time to detect AND mean time to deploy - both matter
5. **Education**: Lunch-and-learns on AI security for data scientists"

### Q8: What is the MITRE ATLAS framework and how does it apply here?
**Answer**:
"MITRE ATLAS (Adversarial Threat Landscape for AI Systems) is like MITRE ATT&CK
but specifically for AI/ML attacks. It maps attack tactics and techniques:
- **ML Supply Chain Compromise**: ATT&CK for poisoning training pipelines
- **Model Inversion**: Extracting training data from model predictions
- **Adversarial Examples**: Crafted inputs that fool the model
- **Model Extraction**: Reconstructing model via API queries

For Interos specifically, I'd map ATLAS techniques to supply chain risk:
- T0010 (Acquire Public ML Artifacts) - public supply chain datasets
- T0031 (Evade ML Model) - manipulate supplier data to get low risk score
- T0040 (Backdoor ML Model) - insert hidden behavior in risk scoring model"

### Q9: Describe a security incident response for a potentially poisoned model
**Answer**:
"My incident response playbook:
1. **Immediate**: Roll back to last cosign-verified model version
2. **Contain**: Put current endpoint in shadow mode (log but don't serve)
3. **Investigate**: Compare current model weights vs. last known good using
   SageMaker Model Registry artifact hashes
4. **Evidence**: Pull CloudTrail logs for all model registry API calls
5. **Root Cause**: Was it data poisoning or model artifact tampering?
   - Check S3 Object Lock audit log for any override attempts
   - Check training job logs for anomalous data access
6. **Notify**: Alert stakeholders, potentially regulatory bodies if compliance
7. **Remediate**: Re-train from verified clean data, re-sign, re-deploy through
   full approval workflow"

### Q10: How would you build an AI Bill of Materials (AI-BOM)?
**Answer**:
"AI-BOM extends traditional SBOM to capture ML-specific dependencies:
1. **Use Syft** to generate SBOM for Python packages (PyTorch, scikit-learn, etc.)
2. **Capture training data provenance**: dataset name, version, hash, source URL
3. **Record model architecture**: layer types, parameter count, hyperparameters
4. **Document third-party models**: pre-trained weights, fine-tuning datasets
5. **Store in CycloneDX format** for standardized tooling
6. **Automate in CI/CD**: Generate AI-BOM on every training run
7. **Link to vulnerabilities**: Check ML package CVEs via OSV database

This allows us to answer: 'Is any component of our model affected by CVE-2024-XXX?'"

## Key Technologies Flash Cards

| Term | Definition | Why It Matters |
|------|------------|----------------|
| S3 Object Lock | Prevent deletion/modification of S3 objects | Immutable training data |
| cosign | Cryptographically sign OCI artifacts | Verify model authenticity |
| in-toto | Supply chain policy framework | Ensure authorized pipeline steps |
| IRSA | Kubernetes pod-level IAM roles | Least privilege for ML workloads |
| SageMaker Model Monitor | Statistical drift detection | Detect model/data poisoning |
| Falco | Kubernetes runtime threat detection | Catch container compromises |
| KMS CMK | Customer-managed encryption key | Data sovereignty |
| OPA Gatekeeper | Kubernetes admission controller | Enforce security policies |

## Practice Scenario
"Your threat model for Interos shows that a nation-state actor wants to
manipulate your supply chain risk scores to protect a sanctioned supplier.
How would they attack and how would you defend?"

Attack path:
1. Compromise a data engineer's credentials
2. Inject mislabeled training examples (supplier X = low risk)
3. Wait for model re-training
4. Model now scores sanctioned supplier as safe
5. Interos customers unknowingly use the sanctioned supplier

Defense:
1. MFA + hardware keys for all data engineers
2. S3 Object Lock prevents retroactive data modification
3. Data validation pipeline detects statistical anomalies in labels
4. Model comparison: new model vs. old model on known-good test set
5. SageMaker Clarify for bias detection (why did score change?)
6. Multi-party approval: data team + ML team + security team must approve
