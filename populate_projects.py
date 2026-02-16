#!/usr/bin/env python3
import os
import shutil

# Source folder
source = 'Project 1-Enterprise SIEM pipeline'

# Target folders
targets = [
    'Project 2- Fedramp-Compliance-Automation',
    'Project 3-Terraform Policy Enforcement',
    'Project 4-MLOps Model Registry',
    'Project 5-Supply Chain Risk API',
    'Project 6- AI Security SBOM Pipeline',
    'Project 7-Infrastructure Drift Detection',
    'Project 8- Kubernetes Security Hardening',
    'Project 9-Serverless Data Pipeline',
    'Project 10- Multi Account AWS Governance',
    'Project 11- Incident Response Orchestration',
    'Project 12- AI Threat Modeling Framework'
]

# Files to copy
files = [
    'README.md',
    'IMPLEMENTATION_GUIDE.md',
    'SECURITY_CONTROLS.md',
    'ARCHITECTURE_DECISION_RECORDS.md',
    'DEPLOYMENT_RUNBOOK.md',
    'TESTING_PLAN.md'
]

for target in targets:
    print(f'Populating {target}...')
    os.makedirs(target, exist_ok=True)
    for file in files:
        src = f'{source}/{file}'
        dst = f'{target}/{file}'
        if os.path.exists(src):
            shutil.copy2(src, dst)
            print(f'  ✓ Copied {file}')
    print()

print('All folders populated!')
