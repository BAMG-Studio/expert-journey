# THE USER JOURNEY (The "Who") - Actors & Personas
## "Who Dey Use This Thing?"

---

## Actors & Personas

### Persona 1: Security Engineer (That's YOU, Peter!)
**Role**: Application Security Engineer
**Daily Tasks**:
- Review GuardDuty findings for AI/ML infrastructure threats
- Scan ML model containers for vulnerabilities (Trivy, Grype)
- Generate SBOMs for model dependencies (Syft, CycloneDX)
- Enforce security gates in CI/CD pipelines
- Respond to security incidents (automated + manual)

**Pidgin**: "Na you be the person wey dey make sure say bad guys no
fit enter. You dey watch everything - from the training data wey dey
S3 to the model wey dey serve predictions. If anything move wey no
supposed to move, na you go first know!"

### Persona 2: Data Scientist / ML Engineer
**Role**: Builds and trains ML models
**Daily Tasks**:
- Prepare training datasets
- Train models using SageMaker
- Deploy models to inference endpoints
- Monitor model performance (accuracy, drift)

**Pidgin**: "This person na the one wey dey build the AI brain.
Dem dey use data to teach computer how to think. But dem no
supposed to touch security controls - na your job be dat!"

### Persona 3: DevOps / Platform Engineer
**Role**: Manages infrastructure and CI/CD pipelines
**Daily Tasks**:
- Maintain Terraform infrastructure
- Manage EKS clusters and container orchestration
- Configure GitHub Actions workflows
- Monitor system health and performance

**Pidgin**: "This person dey make sure say the house strong.
Dem build the road (infrastructure) wey the AI dey travel on.
You (security engineer) dey make sure say robbers no dey
for the road."

### Persona 4: Compliance Officer / Auditor
**Role**: Ensures regulatory compliance
**Daily Tasks**:
- Review AWS Config compliance reports
- Prepare FedRAMP audit evidence
- Validate NIST 800-53 control implementation
- Generate compliance dashboards

**Pidgin**: "This one na the person wey government send come
check whether you dey follow the rules. Dem go look your
Config rules, your CloudTrail logs, your SIEM dashboards.
If everything green, you pass. If red, wahala dey!"

### Persona 5: Threat Actor / Adversary (The Bad Guy)
**Role**: Tries to compromise AI systems
**Attack Methods**:
- Model poisoning (inject bad training data)
- Prompt injection (manipulate LLM outputs)
- Data exfiltration (steal training datasets)
- Model extraction (steal model weights)
- Supply chain attacks (compromise ML libraries)

**Pidgin**: "Omo, this one na the enemy! Dem dey try every
trick to spoil your AI or steal your data. Some na hackers,
some na nation-state actors (government-backed hackers from
other countries). We dey build defense against ALL of dem!"

---

## User Interaction Flow

```
Data Scientist          Security Engineer        Compliance Officer
     |                        |                        |
     |-- Trains Model ------->|                        |
     |                        |-- Scans for vulns      |
     |                        |-- Signs model (cosign) |
     |                        |-- Deploys to staging    |
     |                        |                        |
     |                        |-- Generates SBOM ------>|
     |                        |-- Config compliance --->|
     |                        |                        |
     |<--- Approved model ----|                        |
     |                        |                        |
     |-- Monitors drift       |-- Monitors threats     |-- Reviews reports
```

> **Sisi Lola Voice**: "You see how everybody get their own role?
> Na teamwork! The data scientist dey cook the food (build model),
> you (security engineer) dey taste am make sure say nobody put
> poison (vulnerabilities), and the compliance officer dey check
> say the kitchen follow health regulations (FedRAMP). Teamwork
> make the dream work, abi?"
