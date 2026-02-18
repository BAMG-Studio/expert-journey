#!/bin/bash
# =============================================================================
# VALIDATION SCRIPT - Pre-deployment checks
# =============================================================================
set -euo pipefail

echo "=== Running Pre-Deployment Validation ==="

# Check tools
echo "[1/5] Checking required tools..."
for cmd in terraform aws python3 docker; do
    if command -v $cmd &>/dev/null; then
        echo "  OK: $cmd found"
    else
        echo "  MISSING: $cmd"
    fi
done

# Terraform validation
echo "[2/5] Validating Terraform..."
cd terraform
terraform init -backend=false > /dev/null 2>&1
terraform validate
terraform fmt -check -recursive || echo "  WARNING: Format issues found"
cd ..

# Python lint
echo "[3/5] Checking Python code..."
python3 -m py_compile lambda/normalizers/guardduty_normalizer.py 2>/dev/null && echo "  OK: guardduty_normalizer.py" || echo "  ERROR: guardduty_normalizer.py"
python3 -m py_compile lambda/normalizers/cloudtrail_normalizer.py 2>/dev/null && echo "  OK: cloudtrail_normalizer.py" || echo "  ERROR: cloudtrail_normalizer.py"
python3 -m py_compile lambda/normalizers/securityhub_normalizer.py 2>/dev/null && echo "  OK: securityhub_normalizer.py" || echo "  ERROR: securityhub_normalizer.py"

# Check destroy script
echo "[4/5] Checking TERRAFORM_DESTROY.sh..."
[ -x TERRAFORM_DESTROY.sh ] && echo "  OK: Destroy script exists and is executable" || echo "  WARNING: Destroy script not executable"

# Docker check
echo "[5/5] Checking Docker..."
docker info > /dev/null 2>&1 && echo "  OK: Docker running" || echo "  WARNING: Docker not available"

echo "=== Validation Complete ==="
