import os, textwrap

BASE = '.'

def w(path, content):
    os.makedirs(os.path.dirname(os.path.join(BASE, path)), exist_ok=True)
    with open(os.path.join(BASE, path), 'w') as f:
        f.write(textwrap.dedent(content).lstrip())
    print(f'  [OK] {path}')

# ============================================================
# PHASE 1: Create all directory structures
# ============================================================
print('\n=== PHASE 1: Creating Directory Structure ===')
dirs = [
    'terraform/modules/kms', 'terraform/modules/s3-log-archive',
    'terraform/modules/cloudtrail', 'terraform/modules/kinesis-firehose',
    'terraform/modules/opensearch', 'terraform/modules/eventbridge',
    'terraform/modules/lambda-normalizers', 'terraform/modules/vpc',
    'terraform/environments/dev', 'terraform/environments/prod',
    'lambda/normalizers', 'lambda/enrichment', 'lambda/tests',
    'opensearch/index-templates', 'opensearch/dashboards',
    'opensearch/ilm-policies', 'opensearch/alerting',
    'tests/unit', 'tests/integration', 'tests/compliance', 'tests/moto-tests',
    'docs/architecture', 'docs/guides', 'docs/runbooks', 'docs/compliance',
    'docs/terminal-commands', 'scripts', '.github/workflows', 'localstack',
]
for d in dirs:
    os.makedirs(os.path.join(BASE, d), exist_ok=True)
    print(f'  [DIR] {d}')
print(f'  Total: {len(dirs)} directories\n')
