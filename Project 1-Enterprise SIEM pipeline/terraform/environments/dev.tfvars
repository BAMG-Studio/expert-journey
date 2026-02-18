# =============================================================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# =============================================================================
# Cost-optimized settings for development and testing.
# Uses LocalStack where possible to minimize AWS costs.
# =============================================================================

project_name = "enterprise-siem"
environment  = "dev"
aws_region   = "us-east-1"
owner_email  = "dev@example.com"

# Feature Flags - Disable expensive services in dev
enable_guardduty   = false
enable_cloudtrail  = false
enable_securityhub = false
enable_macie       = false

# LocalStack - Enable for zero-cost local development
use_localstack       = true
localstack_endpoint  = "http://localhost:4566"

# OpenSearch - Minimal configuration for dev
opensearch_instance_type  = "t3.small.search"
opensearch_instance_count = 1
opensearch_ebs_size       = 10
opensearch_version        = "OpenSearch_2.11"
opensearch_master_user    = "admin"
# Password must be set via environment variable: TF_VAR_opensearch_master_password

# Kinesis - Fast delivery for testing
firehose_buffer_size      = 1
firehose_buffer_interval  = 60

# Storage - Short retention for dev
log_retention_days = 7
enable_cross_region_replication = false
