
# Skill 2: AI Threat Modeling & Adversarial Defense

## What This Skill Covers
Systematically identifying, analyzing, and mitigating threats specific to
AI/ML systems using industry frameworks: MITRE ATLAS and OWASP LLM Top 10.

## Why This Differs from Traditional Threat Modeling
Traditional threat modeling (STRIDE) focuses on software vulnerabilities.
AI threat modeling adds unique attack surfaces:
- Training data as an attack vector
- Model behavior manipulation
- LLM prompt injection
- AI system trust exploitation

## Two Core Frameworks

### MITRE ATLAS
- **Full Name**: Adversarial Threat Landscape for AI Systems
- **Covers**: ML-specific attacks (not LLMs exclusively)
- **Structure**: Tactics -> Techniques -> Procedures (same as ATT&CK)
- **Use Case**: Threat modeling traditional ML systems (like Interos risk models)
- **URL**: https://atlas.mitre.org

### OWASP LLM Top 10
- **Covers**: Risks specific to Large Language Model applications
- **Structure**: Ranked list of vulnerabilities with examples
- **Use Case**: Any product with ChatGPT-style features
- **Current Version**: OWASP LLM Top 10 v1.1 (2024)

## Skill Learning Path
1. Day 1: MITRE ATLAS Framework Deep Dive
2. Day 2: OWASP LLM Top 10 with Attack Demonstrations
3. Day 3: Threat Modeling a Supply Chain AI System
4. Day 4: Adversarial Defenses (防御) Implementation
5. Day 5: Interview Prep + Practice Scenarios

## Pidgin Summary
Threat modeling be like say you dey think like thief before you build:
- ATLAS tell you how people attack AI systems
- OWASP tell you how people attack ChatGPT-type apps
- You use both to find wahala before wahala find you
