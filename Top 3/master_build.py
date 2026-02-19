import os

def w(path, content):
    d = os.path.dirname(path)
    if d:
        os.makedirs(d, exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f'  [CREATED] {path}')

print('\n' + '='*60)
print('  TOP 3 MASTER BUILD - OMO WE DEY SCATTER!')
print('='*60 + '\n')

# BLUEPRINT 05 - DATA LAYER
blueprint_05 = """
# THE FILING CABINET (The Where Data Lives) - Data Layer
## Omo, Na Where We Keep All Our Sensitive Gist!

## AWS S3 (Simple Storage Service) - The Main Filing Cabinet
S3 na like super filing cabinet for cloud. You fit store
anything there - training data, model artifacts, logs,
compliance reports - everything.

### Security Controls on S3 for AI/ML

1. OBJECT LOCK (Immutable Storage)
   - What: Once data dey inside, NOBODY fit delete or modify am
   - Why: Prevents data poisoning attacks on training data
   - Pidgin: Like say you write something for stone - e dey there forever!
   - Compliance mode: Even root account (highest admin) cannot delete!

2. KMS ENCRYPTION (Key Management Service)
   - What: All data encrypted - unreadable without the key
   - Why: Even if attacker steals the data, dem cannot read am
   - Pidgin: Like writing your diary in secret code

3. VERSIONING
   - What: S3 keeps every version of every file
   - Why: If attacker corrupts a file, we can restore previous version
   - Pidgin: Like say Word document dey save history of every edit

4. BUCKET POLICIES + IAM
   - What: Strict rules on who can read/write/delete
   - Why: Principle of Least Privilege - person only get what dem need
   - Pidgin: Like say receptionist only get key to reception, not all offices

### Training Data Architecture

```
S3 Bucket: top3-training-data-secure
|-- raw-data/              # Original training data (Object Lock: 7 years)
|   |-- supplier-graph-2026-02-18.parquet  # Hash: sha256:a3f5...
|-- processed-features/    # Engineered features (versioned)
|-- model-artifacts/       # Trained models (cosign signed)
|   |-- i-score-v2.5/
|   |   |-- model.pkl      # The actual model
|   |   |-- sbom.json      # What libraries dey inside
|   |   |-- model.sig      # Cryptographic signature
|-- compliance-evidence/   # Audit reports (Object Lock: 7 years)
```

## DynamoDB - The Fast Lookup Table
For things wey need quick access:
- Incident response audit trail (every action logged here)
- Model metadata registry (which model dey in production)
- SBOM vulnerability cache (scan results)

## OpenSearch - The SIEM Search Engine
50GB/day of security logs searchable in real-time:
- Who accessed what and when (CloudTrail logs)
- Network traffic patterns (VPC Flow Logs)
- Security findings (GuardDuty events)
- Compliance status (Config rule evaluations)

> Sisi Lola: Omo! Data na gold. We dey protect am like CBN gold reserves!
> Every file encrypted, every access logged, every version saved.
> Even if bad guy enter, dem no fit carry anything useful!
"""
w('Architectural-Blueprint/05-THE-FILING-CABINET.md', blueprint_05)
