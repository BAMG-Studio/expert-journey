# =============================================================
# PROD Environment Configuration
# =============================================================
# PRODUCTION settings - higher availability, more resources.
# Use with: terraform plan -var-file=environments/prod/prod.tfvars

environment     = "prod"
project_name    = "siem-pipeline"
aws_region      = "us-east-1"

# Production-grade instances
opensearch_instance_type  = "r6g.large.search"
opensearch_instance_count = 3
opensearch_volume_size    = 500

# Lambda settings
lambda_memory_size = 512
lambda_timeout     = 300

# Retention (longer for compliance)
log_retention_days = 365
s3_lifecycle_days  = 365

# High availability
enable_multi_az       = true
enable_dedicated_master = true

# Tags
tags = {
  Environment = "prod"
  Project     = "Enterprise-SIEM"
  ManagedBy   = "Terraform"
  Compliance  = "SOC2"
}
