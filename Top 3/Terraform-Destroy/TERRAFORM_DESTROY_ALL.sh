#!/bin/bash
###############################################################################
# TERRAFORM DESTROY ALL - MANUAL EXECUTION ONLY
# ============================================================================
# Omo! This script go wipe EVERYTHING clean. All AWS resources wey Terraform
# provision for this project go comot. Na manual execution ONLY o!
#
# USAGE: bash Terraform-Destroy/TERRAFORM_DESTROY_ALL.sh
# WARNING: This action no dey reversible! Once you run am, e don go be dat!
###############################################################################

set -euo pipefail

# Colors for output (make am fine to look at)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}"
echo "============================================================"
echo "  WARNING: TERRAFORM DESTROY ALL RESOURCES"
echo "  Omo! You sure say you wan delete everything?"
echo "  This action NO dey reversible o!"
echo "============================================================"
echo -e "${NC}"

# Safety confirmation (triple check!)
read -p "Type 'YES-DESTROY-ALL' to confirm: " CONFIRM
if [ "$CONFIRM" != "YES-DESTROY-ALL" ]; then
    echo -e "${GREEN}Phew! Operation cancelled. Your resources dey safe.${NC}"
    exit 0
fi

read -p "Are you ABSOLUTELY sure? (yes/no): " CONFIRM2
if [ "$CONFIRM2" != "yes" ]; then
    echo -e "${GREEN}Good choice! Nothing was destroyed.${NC}"
    exit 0
fi

echo -e "${YELLOW}Starting destruction sequence...${NC}"

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Function to destroy Terraform resources in a directory
destroy_terraform() {
    local dir=$1
    local name=$2
    
    if [ -d "$dir" ] && [ -f "$dir/main.tf" ]; then
        echo -e "${YELLOW}Destroying: $name${NC}"
        cd "$dir"
        terraform init -input=false 2>/dev/null || true
        terraform destroy -auto-approve -input=false 2>/dev/null || {
            echo -e "${RED}Warning: Failed to destroy $name - may need manual cleanup${NC}"
        }
        cd "$PROJECT_ROOT"
        echo -e "${GREEN}Completed: $name${NC}"
    else
        echo "Skipping $name (no Terraform files found)"
    fi
}

# Destroy in reverse order (dependencies last)
echo ""
echo "Phase 1: Destroying Skill 3 - AI Governance & Compliance resources..."
destroy_terraform "$PROJECT_ROOT/03-Skill-3-AI-Governance-Compliance/src/terraform" "Skill 3 Infrastructure"

echo ""
echo "Phase 2: Destroying Skill 2 - AI Threat Modeling resources..."
destroy_terraform "$PROJECT_ROOT/02-Skill-2-AI-Threat-Modeling/src/terraform" "Skill 2 Infrastructure"

echo ""
echo "Phase 3: Destroying Skill 1 - AI/ML Security Engineering resources..."
destroy_terraform "$PROJECT_ROOT/01-Skill-1-AI-ML-Security-Engineering/src/terraform" "Skill 1 Infrastructure"

# Stop LocalStack if running
echo ""
echo "Phase 4: Stopping LocalStack containers..."
if [ -f "$PROJECT_ROOT/LocalStack-Setup/docker-compose.yml" ]; then
    cd "$PROJECT_ROOT/LocalStack-Setup"
    docker-compose down -v 2>/dev/null || true
    cd "$PROJECT_ROOT"
fi

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  DESTRUCTION COMPLETE - All resources don comot!${NC}"
echo -e "${GREEN}  Sisi Lola say: 'Clean slate, fresh start!'${NC}"
echo -e "${GREEN}============================================================${NC}"
