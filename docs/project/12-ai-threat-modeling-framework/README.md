# AI Threat Modeling Framework

## Overview

> **Mentor Note**: Threat modeling is like creating a security blueprint before building a house - you identify all the ways someone could break in and plan defenses in advance. This project uses AI to automate and enhance that process, analyzing system architectures to identify threats that humans might miss.

This project implements an AI-powered threat modeling framework that automatically analyzes system architectures, identifies potential threats using STRIDE methodology, and generates prioritized remediation recommendations. It integrates with architecture diagrams and infrastructure-as-code to provide continuous threat assessment.

### Why This Matters

- Manual threat modeling is time-consuming and requires expert knowledge
- Architecture changes often outpace security reviews
- STRIDE and MITRE ATT&CK mapping requires deep security expertise
- Continuous threat assessment catches risks as systems evolve

---

## Architecture

```
+------------------+     +------------------+     +------------------+
|  System Input    |---->|  AI Analysis     |---->|  Threat Report   |
|  - Architecture  |     |  Engine          |     |  Generator       |
|  - IaC (Terraform)|    |  (LLM + Rules)   |     |                  |
|  - Data Flow     |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
                                  |                        |
                                  v                        v
                          +------------------+     +------------------+
                          |  STRIDE Analysis |     |  MITRE ATT&CK   |
                          |  Classifier      |     |  Mapping         |
                          +------------------+     +------------------+
                                  |                        |
                                  v                        v
                          +----------------------------------+
                          |  Prioritized Threat Matrix       |
                          |  with Remediation Guidance       |
                          +----------------------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Input Parser | Python + HCL parser | Parse architecture and IaC inputs |
| AI Engine | LLM (GPT-4/Claude) + Rules | Identify threats and attack vectors |
| STRIDE Classifier | Custom ML model | Categorize threats by STRIDE |
| MITRE Mapper | ATT&CK API integration | Map threats to MITRE techniques |
| Report Generator | Jinja2 + Markdown | Produce actionable reports |
| Dashboard | Streamlit | Interactive threat visualization |

---

## Core Concepts

### STRIDE Threat Categories

| Category | Description | Example |
|----------|-----------|----------|
| **S**poofing | Impersonating another entity | Stolen API keys |
| **T**ampering | Modifying data in transit/rest | Man-in-the-middle attack |
| **R**epudiation | Denying actions taken | Missing audit logs |
| **I**nformation Disclosure | Exposing sensitive data | Unencrypted S3 bucket |
| **D**enial of Service | Making service unavailable | DDoS attack |
| **E**levation of Privilege | Gaining unauthorized access | IAM privilege escalation |

### Threat Modeling Process

1. **Decompose** - Break system into components and data flows
2. **Identify** - Find threats for each component using STRIDE
3. **Rate** - Assess likelihood and impact (DREAD scoring)
4. **Mitigate** - Define countermeasures for each threat
5. **Validate** - Verify mitigations are implemented

---

## Implementation Guide

### Step 1: Architecture Parser

```python
import hcl2
import json

def parse_terraform(tf_directory):
    """Extract system components from Terraform files."""
    components = []
    
    for tf_file in Path(tf_directory).glob("**/*.tf"):
        with open(tf_file) as f:
            config = hcl2.load(f)
        
        for resource_type, resources in config.get("resource", [{}])[0].items():
            for name, props in resources.items():
                components.append({
                    "type": resource_type,
                    "name": name,
                    "properties": props,
                    "data_flows": extract_data_flows(props),
                    "trust_boundary": determine_trust_boundary(resource_type)
                })
    
    return components
```

### Step 2: AI Threat Analysis

```python
from openai import OpenAI

def analyze_threats(components, data_flows):
    """Use LLM to identify threats in the architecture."""
    client = OpenAI()
    
    prompt = f"""Analyze the following cloud architecture for security threats
    using STRIDE methodology. For each threat identified, provide:
    1. STRIDE category
    2. Threat description
    3. Affected component
    4. Likelihood (1-5)
    5. Impact (1-5)
    6. MITRE ATT&CK technique ID
    7. Recommended mitigation
    
    Architecture components:
    {json.dumps(components, indent=2)}
    
    Data flows:
    {json.dumps(data_flows, indent=2)}
    """
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.2
    )
    
    return parse_threat_response(response.choices[0].message.content)
```

### Step 3: MITRE ATT&CK Mapping

```python
def map_to_mitre(threats):
    """Map identified threats to MITRE ATT&CK techniques."""
    mitre_mapping = {
        "Spoofing": ["T1078", "T1098", "T1134"],
        "Tampering": ["T1565", "T1036", "T1070"],
        "Repudiation": ["T1070.001", "T1562.001"],
        "InformationDisclosure": ["T1530", "T1552", "T1040"],
        "DenialOfService": ["T1499", "T1498"],
        "ElevationOfPrivilege": ["T1548", "T1068", "T1078.004"]
    }
    
    for threat in threats:
        category = threat["stride_category"]
        threat["mitre_techniques"] = mitre_mapping.get(category, [])
        threat["mitre_details"] = [
            fetch_mitre_technique(t) for t in threat["mitre_techniques"]
        ]
    
    return threats
```

### Step 4: Report Generation

```python
from jinja2 import Template

def generate_report(threats, output_path):
    """Generate markdown threat model report."""
    template = Template(open("templates/threat_report.md.j2").read())
    
    report = template.render(
        project_name="Target System",
        date=datetime.utcnow().strftime("%Y-%m-%d"),
        total_threats=len(threats),
        critical=len([t for t in threats if t["risk_score"] > 20]),
        high=len([t for t in threats if 15 < t["risk_score"] <= 20]),
        threats=sorted(threats, key=lambda t: t["risk_score"], reverse=True)
    )
    
    with open(output_path, "w") as f:
        f.write(report)
```

---

## Deployment

### Prerequisites

- Python 3.11+
- OpenAI API key (or AWS Bedrock for Claude)
- Terraform files or architecture diagrams as input

### Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Analyze Terraform directory
python threat_model.py --input terraform/ --output report.md

# Run interactive dashboard
streamlit run dashboard.py

# Generate STRIDE analysis
python stride_analysis.py --architecture arch.json
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Full threat model | `python threat_model.py --input <dir> --output report.md` |
| STRIDE only | `python stride_analysis.py --architecture arch.json` |
| MITRE mapping | `python mitre_mapper.py --threats threats.json` |
| Interactive mode | `streamlit run dashboard.py` |

### Links
- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [STRIDE Methodology](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [Threat Modeling Manifesto](https://www.threatmodelingmanifesto.org/)
