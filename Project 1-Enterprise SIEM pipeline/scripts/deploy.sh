#!/bin/bash
# =============================================================================
# DEPLOY SCRIPT - Enterprise SIEM Pipeline
# =============================================================================
set -euo pipefail

ENV=${1:-dev}
ACTION=${2:-plan}

echo "=== Enterprise SIEM Pipeline Deployment ==="
echo "Environment: $ENV"
echo "Action: $ACTION"

cd terraform

# Initialize
terraform init

# Validate
terraform validate

case $ACTION in
  plan)
    terraform plan -var-file=environments/${ENV}.tfvars
    ;;
  apply)
    terraform plan -var-file=environments/${ENV}.tfvars -out=tfplan
    terraform apply tfplan
    rm -f tfplan
    echo "=== Deployment Complete ==="
    terraform output
    ;;
  *)
    echo "Usage: $0 [dev|staging|prod] [plan|apply]"
    exit 1
    ;;
esac
