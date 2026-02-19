# THE CONTEXT (The "Why") - Problem Statement & Business Objectives
## "Omo, Why We Dey Do All This Wahala?"

---

## Problem Statement

### The Real-World Problem (Plain English)
Organizations wey dey deploy AI/ML (Artificial Intelligence / Machine Learning) systems
for production dey face SERIOUS security challenges wey traditional security tools no
fit handle. Na like say you dey use padlock to guard bank vault - the old security
no match the new threats.

### Pidgin Breakdown
**Omo, see wetin dey happen**: Companies dey build AI models wey dey make important
decisions - like who get loan, which supplier dey risky, whether email na spam. But
these AI systems get their own special wahala:

1. **Model Poisoning** - Bad guys fit inject bad data during training, so the model
   go dey give wrong answers. Na like say somebody put sand inside your garri before
   you soak am - you go chop am thinking say e good, but e don spoil.

2. **Prompt Injection** - For LLM (Large Language Model) systems, attackers fit
   trick the AI to ignore its instructions. Na like say you tell security guard
   "oga say make you open gate" when oga never talk anything.

3. **Training Data Theft** - Your training data na your competitive advantage.
   If person steal am, dem fit build their own competing product. Na like say
   someone photocopy your secret recipe.

4. **Model Extraction** - Attackers fit query your model many many times to
   basically steal how e work. Na like say person dey ask you interview questions
   until dem know everything you know.

---

## Business Objectives

### Primary Objectives
| # | Objective | Success Metric | Pidgin Translation |
|---|-----------|----------------|--------------------|
| 1 | Secure AI/ML training pipelines | Zero unauthorized data modifications | "Nobody fit touch our training data anyhow" |
| 2 | Protect model intellectual property | Zero model theft incidents | "Our AI brain dey safe" |
| 3 | Achieve FedRAMP compliance for AI systems | 95%+ compliance score within 30 days | "Government go approve our system" |
| 4 | Automate threat detection & response | MTTR < 60 seconds | "We go catch bad guys before dem blink" |
| 5 | Implement AI governance framework | Full NIST AI RMF coverage | "Everything dey follow the rules" |

### Why This Matters for Interos (Business Context)
Interos operates an AI-powered supply chain risk intelligence platform that:
- Maps **230+ million entities** and **11+ billion supplier-buyer relationships**
- Serves **U.S. Department of Defense, NASA, Five Eyes nations**
- Holds a **$919M GSA SCRIPTS BPA** (10-year government contract)
- Uses ML models (i-Score) to assess risk across 6 dimensions

**If the AI gets compromised, national security gets compromised.**

> **Sisi Lola Voice**: "Omo, you see why this thing important? If bad guys
> poison the AI model wey dey tell government which supplier dey safe,
> dem fit sneak dangerous supplier into military supply chain. Na so
> serious e be! That's why we dey learn all this - we dey protect
> country, not just write code!"

---

## The Three Pillars We Are Building

### Pillar 1: AI/ML Security Engineering
**What**: Hands-on securing of AI workloads on AWS
**Why**: Because AI models na the new crown jewels
**How**: S3 Object Lock, KMS encryption, cosign model signing, SageMaker VPC isolation

### Pillar 2: AI Threat Modeling & Adversarial Defense  
**What**: Finding vulnerabilities before attackers do
**Why**: Traditional threat models no cover AI-specific attacks
**How**: MITRE ATLAS framework, OWASP LLM Top 10, adversarial testing

### Pillar 3: AI Governance & Compliance
**What**: Making sure everything follows government rules
**Why**: FedRAMP, NIST 800-53, CMMC required for government contracts
**How**: AWS Config rules, Security Hub, OpenSearch SIEM, automated compliance reporting

---

## Key Acronyms & Terms (Cheat Sheet)

| Acronym | Full Name | Pidgin Explanation |
|---------|-----------|--------------------|
| **AI** | Artificial Intelligence | Computer wey fit think small |
| **ML** | Machine Learning | Computer wey dey learn from data |
| **LLM** | Large Language Model | Big AI wey fit read and write like human (e.g., ChatGPT) |
| **SBOM** | Software Bill of Materials | List of everything wey dey inside your software |
| **NIST** | National Institute of Standards and Technology | Government body wey make the rules |
| **FedRAMP** | Federal Risk and Authorization Management Program | Government approval for cloud services |
| **SIEM** | Security Information and Event Management | Security camera system for your cloud |
| **MTTR** | Mean Time To Respond | How fast you fit respond to attack |
| **SageMaker** | AWS SageMaker | AWS service for building/training/deploying ML models |
| **EKS** | Elastic Kubernetes Service | AWS managed Kubernetes for running containers |
| **KMS** | Key Management Service | AWS service for encryption keys |
| **cosign** | Container/Artifact Signing | Tool for digitally signing things (like putting stamp on document) |
| **in-toto** | In Total (Latin) | Framework wey prove software no get tampered |
| **MITRE ATLAS** | Adversarial Threat Landscape for AI Systems | Catalog of how bad guys attack AI |
| **OWASP** | Open Worldwide Application Security Project | Organization wey track security problems |
| **DISA STIGs** | Defense Information Systems Agency Security Technical Implementation Guides | Military security configuration guides |
| **RMF** | Risk Management Framework | How government manage security risk |
| **CMMC** | Cybersecurity Maturity Model Certification | Defense contractor security certification |

---

> **Next Step**: Read `02-THE-USER-JOURNEY-THE-WHO.md` to understand who uses these systems.
