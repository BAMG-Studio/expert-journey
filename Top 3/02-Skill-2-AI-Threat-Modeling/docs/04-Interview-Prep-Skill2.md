# Skill 2 Interview Prep: AI Threat Modeling

## Q1: Walk me through threat modeling an AI-powered supply chain risk system
Answer:
"I would use a hybrid approach combining STRIDE for traditional components and
MITRE ATLAS for ML-specific threats:

1. SYSTEM DECOMPOSITION:
   - Data ingestion layer (APIs, web scrapers, partner feeds)
   - Training pipeline (SageMaker, S3, Lambda)
   - Model registry (ECR, SageMaker Model Registry)
   - Inference endpoint (EKS, API Gateway)
   - Customer-facing dashboard (React, GraphQL)

2. TRUST BOUNDARIES:
   - External data sources -> internal data lake (UNTRUSTED)
   - Data lake -> training pipeline (SEMI-TRUSTED)
   - Training pipeline -> model registry (TRUSTED with attestation)
   - Model registry -> inference endpoint (TRUSTED with signature)
   - Inference endpoint -> customer (AUTHENTICATED)

3. ATLAS TECHNIQUE MAPPING:
   - T0010: Supply chain compromise of ML dependencies
   - T0020: Data poisoning via compromised data sources
   - T0031: Model evasion via crafted supplier profiles
   - T0040: Backdoor ML model via insider threat
   - T0024: Data exfiltration via inference API

4. PRIORITIZED CONTROLS:
   HIGH: S3 Object Lock, cosign model signing, IRSA
   MEDIUM: Input validation, rate limiting, model monitoring
   LOW: Output noise, adversarial training"

## Q2: Explain prompt injection vs traditional SQL injection
Answer:
- SQL Injection: attacker sends malicious SQL that database executes as code
- Prompt Injection: attacker sends text that LLM interprets as new instructions
- Key difference: SQL injection exploits lack of input/code separation.
  Prompt injection exploits the fundamental nature of LLMs - they cannot
  reliably distinguish instructions from data
- Defense parallel: parameterized queries vs context separation + input validation

## Q3: How would you detect a data poisoning attack in progress?
Answer:
"Multi-layer detection:
1. STATISTICAL: Monitor training data distributions over time. Alert on:
   - Label distribution shifts beyond 2 standard deviations
   - New feature values outside historical ranges
   - Sudden increase in near-duplicate records
2. BEHAVIORAL: Compare new model vs previous model:
   - Run both on golden test set
   - If predictions diverge by >5% on any category, investigate
3. LINEAGE: Check data provenance chain:
   - Every record traced to source with timestamp
   - New data sources require security review
4. HUMAN: Regular review of random data samples by domain experts"

## Q4: ATLAS vs ATT&CK - when do you use which?
Answer:
"ATT&CK covers traditional cyber attacks (phishing, malware, lateral movement).
ATLAS specifically covers AI/ML attacks. For a company like Interos, you need BOTH:
- ATT&CK: How attackers get initial access to your infrastructure
- ATLAS: Once inside, how they specifically target your ML systems

Example: Attacker phishes an ML engineer (ATT&CK T1566), gets into AWS (ATT&CK
T1078), then poisons training data (ATLAS T0020). The kill chain spans both
frameworks. My threat model maps the complete attack path across both."

## Q5: What is the OWASP LLM Top 10 and how does it apply to Interos?
Answer:
"If Interos is adding LLM features (like natural language supply chain queries),
the OWASP LLM Top 10 becomes critical:

LLM01 Prompt Injection: Customer could inject instructions via natural language
  query to access other customers' data
LLM03 Training Data Poisoning: If LLM is fine-tuned on supply chain data,
  poisoned data could make LLM give wrong advice
LLM06 Sensitive Information: LLM might reveal proprietary risk scores or
  training data details in its responses
LLM08 Excessive Agency: If LLM can take actions (update scores, send alerts),
  prompt injection could trigger unauthorized actions"

## Q6: Design a security review process for new ML models at Interos
Answer:
Pre-Deployment Security Review Checklist:
1. DATA REVIEW: Verify training data provenance and integrity
2. MODEL REVIEW: Check for backdoors using trigger scanning
3. BIAS REVIEW: Run fairness metrics across demographics/geographies
4. PERFORMANCE REVIEW: Compare against golden test set
5. SUPPLY CHAIN: Generate SBOM, check dependency vulnerabilities
6. SIGNATURE: Verify cosign signature and in-toto attestations
7. ACCESS: Confirm IAM roles follow least privilege
8. MONITORING: Verify Model Monitor is configured for drift detection
9. ROLLBACK: Test automated rollback to previous model version
10. APPROVAL: Require sign-off from ML team + security team

## Q7: How do you perform adversarial testing on ML models?
Answer:
"Three levels of adversarial testing:

1. AUTOMATED: Run adversarial example generators
   - For tabular data: perturb features within valid ranges
   - For NLP: synonym substitution, character swaps
   - For images: FGSM, PGD attacks

2. RED TEAM: Security team manually attempts:
   - Data poisoning via compromised data source
   - Model evasion with crafted supplier profiles
   - Prompt injection if LLM features exist
   - Model extraction via systematic API queries

3. PURPLE TEAM: Combined attack + defense exercise:
   - Red team attacks while blue team monitors
   - Evaluate detection time and response effectiveness
   - Update threat model based on findings"

## Q8: Explain differential privacy and how it protects ML training data
Answer:
"Differential privacy adds calibrated noise during training so that:
- Model learns general patterns (good)
- Model cannot memorize individual records (good)
- Attacker querying the model cannot determine if any specific
  record was in the training data (membership inference defense)

Implementation:
- Use DP-SGD (Differentially Private Stochastic Gradient Descent)
- Set epsilon parameter: lower = more private, less accurate
- For supply chain risk: epsilon ~5-10 balances utility and privacy
- TensorFlow Privacy or Opacus (PyTorch) libraries"

## Flash Cards
| Term | Quick Definition |
|------|------------------|
| MITRE ATLAS | ATT&CK framework specifically for AI systems |
| OWASP LLM Top 10 | Top vulnerabilities in LLM applications |
| Prompt Injection | Hijacking LLM behavior via crafted text input |
| Data Poisoning | Corrupting training data to manipulate model |
| Model Extraction | Stealing model behavior by querying API |
| Adversarial Examples | Crafted inputs that fool the model |
| Backdoor Attack | Hidden trigger in model weights |
| Model Inversion | Recovering training data from model |
| Differential Privacy | Mathematical privacy guarantee for training |
| Red Teaming | Adversarial testing by security experts |
