# Skill 3 Interview Prep: AI Governance & Compliance

## Q1: Describe the NIST AI RMF and how you would apply it at Interos
Answer:
"The NIST AI RMF has four functions: Govern, Map, Measure, and Manage.

At Interos, I would apply it as follows:

GOVERN: Establish an AI governance board with CISO, VP Engineering, CDO,
and legal counsel. Create mandatory policies: AI system classification,
model development lifecycle, training data governance.

MAP: Build an AI system inventory. For Interos, critical high-risk systems
would include the supply chain risk scorer and anomaly detection engine.
For each, document: stakeholders, potential harms, data flows, trust boundaries.

MEASURE: Define KPIs for each AI system:
- Accuracy metrics (precision, recall, F1)
- Fairness metrics (demographic parity ratio across geographic regions)
- Drift metrics (distribution shift from baseline)
- Security metrics (adversarial robustness score)

MANAGE: Automated risk responses:
- Bias detected: halt deployment, investigate, retrain with balanced data
- Model drift: trigger automated retraining pipeline
- Security violation: roll back to last signed model version"

## Q2: What NIST 800-53 controls are most critical for securing ML systems?
Answer:
"The four controls I prioritize for ML:

1. AU-2 (Audit Events): I expand standard audit requirements to include
   ML-specific events: training job submissions, model registry approvals,
   inference API calls, S3 Object Lock modification attempts. This provides
   the evidence trail for both security incidents and compliance audits.

2. SC-28 (Data at Rest): Every ML artifact must be encrypted with
   customer-managed KMS keys - training data, model weights, inference
   request/response logs. I enforce this with AWS Config rules and Security Hub.

3. AC-3 (Access Enforcement): ML systems need RBAC that separates:
   who can ACCESS data vs. TRAIN models vs. APPROVE models vs. DEPLOY.
   No single person should have end-to-end access without oversight.

4. RA-5 (Vulnerability Scanning): For ML specifically this means:
   container image scanning (ECR Enhanced Scanning), dependency scanning
   (pip-audit), and ML-specific testing (adversarial robustness)."

## Q3: How do you generate and use an SBOM for ML systems?
Answer:
"SBOM for ML has two layers:

Layer 1 - Traditional: I use Syft to generate a CycloneDX-format SBOM from
the ML container image and Python requirements.txt. This captures all
libraries (PyTorch, scikit-learn, etc.) with their versions and hashes.

Layer 2 - AI-BOM: I extend the SBOM with ML-specific components:
- Training datasets (name, version, hash, source, record count)
- Pre-trained model weights (source URL, hash, license)
- Model architecture (type, size, training hyperparameters)
- Provenance (training job ID, data hash, code commit)

In CI/CD, Grype scans the SBOM against vulnerability databases and
fails the build if any HIGH or CRITICAL CVEs are found.

This answers the key governance question: if we learn that PyTorch 2.1.0
has a critical vulnerability, which of our models is affected?"

## Q4: Explain demographic parity and why it matters for Interos
Answer:
"Demographic parity means the model's positive prediction rate should be
roughly equal across groups.

For Interos, the relevant groups are geographic regions (Americas, EMEA, APAC,
central Asia, etc.). The risk is that our training data might be richer for
some regions than others, causing the model to be less accurate for regions
with sparse data.

If suppliers in Country X are systematically scored as high risk not because
they ARE high risk, but because we have less training data from that region,
that's a fairness failure. Customers using those scores to exclude suppliers
would be making decisions based on data bias, not actual risk.

I use the 80% rule: if the parity ratio between the highest-scoring region
and lowest-scoring region drops below 0.8, we investigate and retrain."

## Q5: What is differential privacy and when would you use it at Interos?
Answer:
"Differential privacy (DP) adds mathematically calibrated noise during
training so that the model cannot reveal whether any individual was in
the training data.

Mathematically: a mechanism M satisfies (epsilon, delta)-DP if:
P[M(D) in S] <= e^epsilon * P[M(D') in S] + delta
where D and D' are datasets differing by one record.

At Interos, I would use DP for:
1. Training data that includes proprietary supplier financial information
   (clients don't want competitors to extract their supplier data via
   the model's outputs)
2. Any model fine-tuned on customer-specific data
3. Risk scores for individual companies where competitive sensitivity
   is high

Implementation: Opacus library for PyTorch. Tradeoff: lower epsilon =
more privacy = less accuracy. For supply chain risk scoring, epsilon 3-5
is a reasonable balance."

## Q6: How would you design FedRAMP continuous monitoring for Interos AI?
Answer:
"FedRAMP continuous monitoring requires automated, evidence-based compliance.
My design:

1. AWS Config: 15+ managed rules enforcing encryption, network isolation,
   logging for all ML resources. Custom rules for SageMaker-specific controls.

2. Security Hub: Aggregates findings from Config, Inspector, GuardDuty,
   Macie into a single compliance dashboard. NIST 800-53 standard enabled.

3. CloudTrail: Multi-region trail logging all API calls. Critical ML events
   (model approvals, training jobs, S3 access) go to separate log group
   with CloudWatch alarms for suspicious patterns.

4. Monthly POA&M (Plan of Action and Milestones): Automated report from
   Security Hub findings, showing:
   - New vulnerabilities discovered
   - Remediation status and timelines
   - Security metrics trends
   - AI-specific metrics (drift, fairness, adversarial test results)

5. Annual assessment: Third-party penetration testing including ML-specific
   attack simulations (data poisoning, model extraction)."

## Q7: How do you create a Model Card and why is it important?
Answer:
"A model card is standardized documentation about an AI model, covering:
- What it does and what it was trained for
- Training data sources and limitations
- Performance metrics including fairness metrics
- Intended and prohibited uses
- Known limitations and failure modes

For Interos, I would require a model card for every production model:
- Who approved it and when
- What training data was used (with hashes for traceability)
- Bias testing results (demographic parity across all geographic regions)
- Edge cases where accuracy degrades
- SBOM reference

Why important: When a customer complains that supplier X has wrong score,
the model card gives us the documentation to investigate. When auditors ask
how we ensure fairness, the model card is our evidence."

## Flash Cards
| Term | Definition |
|------|------------|
| NIST AI RMF | Govern-Map-Measure-Manage framework for AI risk |
| NIST 800-53 | Security/privacy controls catalog (20 families) |
| FedRAMP | Federal cloud security authorization program |
| SBOM | Software Bill of Materials - complete component inventory |
| CycloneDX | SBOM format standard (more detailed than SPDX) |
| Syft | Tool to generate SBOMs from containers and code |
| Grype | Tool to scan SBOMs for vulnerabilities |
| AI-BOM | SBOM extended to include ML-specific components |
| Demographic Parity | Equal prediction rates across protected groups |
| Equalized Odds | Equal error rates across protected groups |
| SHAP | Technique for explaining ML model decisions |
| Model Card | Standardized documentation about an ML model |
| Differential Privacy | Mathematical guarantee of training data privacy |
| Federated Learning | Train on distributed data without centralizing it |
| Responsible AI | Fairness + explainability + privacy in AI systems |
