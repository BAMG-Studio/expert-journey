# =============================================================
# DEV Environment Configuration
# =============================================================
# This file contains variable values for the DEV environment.
# Use with: terraform plan -var-file=environments/dev/dev.tfvars

environment     = "dev"
project_name    = "siem-pipeline"
aws_region      = "us-east-1"

# Smaller instances for cost savings in dev
opensearch_instance_type  = "t3.small.search"
opensearch_instance_count = 1
opensearch_volume_size    = 20

# Lambda settings
lambda_memory_size = 256
lambda_timeout     = 60

# Retention settings (shorter for dev)
log_retention_days = 30
s3_lifecycle_days  = 30

# Cost controls
enable_multi_az       = false
enable_dedicated_master = false

# Tags
tags = {
  Environment = "dev"
  Project     = "Enterprise-SIEM"
  ManagedBy   = "Terraform"
}
