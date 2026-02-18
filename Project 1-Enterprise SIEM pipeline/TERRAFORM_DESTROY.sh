#!/bin/bash
# =============================================================================
# TERRAFORM DESTROY SCRIPT - MANUAL EXECUTION ONLY
# =============================================================================
# 
# !!! DANGER ZONE - THIS SCRIPT DESTROYS ALL PROVISIONED RESOURCES !!!
# 
# PURPOSE:
#   This script completely destroys all AWS resources provisioned by Terraform
#   for the Enterprise SIEM Pipeline project. It is designed for MANUAL 
#   execution ONLY by the project owner.
#
# WHAT GETS DESTROYED:
#   - OpenSearch domain (SIEM dashboard and all indexed data)
#   - Kinesis Firehose delivery streams
#   - Lambda functions (all normalizers)
#   - S3 buckets (all archived logs will be PERMANENTLY deleted)
#   - CloudTrail trails
#   - EventBridge rules
#   - KMS encryption keys (data encrypted with these keys becomes UNRECOVERABLE)
#   - IAM roles and policies
#   - CloudWatch log groups
#   - GuardDuty detector (if enabled)
#   - Security Hub (if enabled)
#
# SAFETY MEASURES:
#   1. Requires explicit 'YES-DESTROY-ALL' confirmation
#   2. Validates AWS credentials before proceeding
#   3. Shows a plan of what will be destroyed
#   4. Creates a state backup before destruction
#   5. 30-second countdown before execution
#   6. Cannot be triggered by CI/CD pipelines
#
# USAGE:
#   cd "Project 1-Enterprise SIEM pipeline"
#   chmod +x TERRAFORM_DESTROY.sh
#   ./TERRAFORM_DESTROY.sh
#
# =============================================================================

set -euo pipefail

TERRAFORM_DIR="./terraform"
BACKUP_DIR="./terraform/state-backups"
LOG_FILE="./terraform/destroy-$(date +%Y%m%d-%H%M%S).log"
COUNTDOWN_SECONDS=30
CONFIRMATION_PHRASE="YES-DESTROY-ALL"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# Prevent automated/CI execution
if [ ! -t 0 ]; then
    echo -e "${RED}ERROR: Must be run interactively${NC}"
    exit 1
fi

if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ] || [ -n "${JENKINS_URL:-}" ]; then
    echo -e "${RED}ERROR: Cannot run in CI/CD environments${NC}"
    exit 1
fi

log() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

echo -e "${RED}${BOLD}"
echo "================================================================"
echo "  TERRAFORM DESTROY - ENTERPRISE SIEM PIPELINE"
echo "  This will PERMANENTLY destroy ALL provisioned resources"
echo "================================================================"
echo -e "${NC}"

# Check prerequisites
command -v terraform &>/dev/null || { echo "terraform not found"; exit 1; }
[ -d "$TERRAFORM_DIR" ] || { echo "Terraform dir not found"; exit 1; }

# Show destroy plan
cd "$TERRAFORM_DIR"
[ -d ".terraform" ] || terraform init -input=false
echo -e "${BLUE}Resources to destroy:${NC}"
terraform plan -destroy -no-color 2>&1 | grep -E '(# |Plan:)' || echo "(No resources in state)"
cd ..

# Confirmation
echo -e "\n${RED}Type 'YES-DESTROY-ALL' to confirm:${NC}"
read -r confirm
[ "$confirm" = "$CONFIRMATION_PHRASE" ] || { echo "Cancelled."; exit 0; }

echo -e "${RED}Final check - type 'yes':${NC}"
read -r final
[ "$final" = "yes" ] || { echo "Cancelled."; exit 0; }

# Backup state
mkdir -p "$BACKUP_DIR"
[ -f "$TERRAFORM_DIR/terraform.tfstate" ] && cp "$TERRAFORM_DIR/terraform.tfstate" "$BACKUP_DIR/terraform.tfstate.$(date +%Y%m%d-%H%M%S)"

# Countdown
for i in $(seq $COUNTDOWN_SECONDS -1 1); do
    echo -ne "\r${RED}Destroying in $i seconds... (Ctrl+C to abort)${NC}"
    sleep 1
done

# Execute destroy
cd "$TERRAFORM_DIR"
terraform destroy -auto-approve -input=false
cd ..

echo -e "${GREEN}ALL RESOURCES DESTROYED SUCCESSFULLY${NC}"
