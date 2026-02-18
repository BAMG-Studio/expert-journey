# =============================================================================
# LOCALSTACK CONFIGURATION - ZERO COST LOCAL DEVELOPMENT
# =============================================================================
# This configuration uses LocalStack to emulate all AWS services locally.
# Perfect for testing Terraform code without any AWS costs.
#
# USAGE:
#   1. Start LocalStack: docker-compose up -d
#   2. Run Terraform: terraform apply -var-file=environments/localstack.tfvars
# =============================================================================

project_name = "siem-local"
environment  = "dev"
aws_region   = "us-east-1"
owner_email  = "local@localhost"

use_localstack      = true
localstack_endpoint = "http://localhost:4566"

# All features disabled for LocalStack (some not fully supported)
enable_guardduty     = false
enable_cloudtrail    = false
enable_securityhub   = false
enable_macie         = false
enable_vpc_flow_logs = false

# Minimal OpenSearch config
opensearch_instance_type    = "t3.small.search"
opensearch_instance_count   = 1
opensearch_ebs_size         = 10
opensearch_master_user      = "admin"
opensearch_master_password  = "LocalStack123!"

# Minimal settings
log_retention_days = 1
