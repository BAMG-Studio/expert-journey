# =============================================================================
# ENTERPRISE SIEM PIPELINE - MAIN TERRAFORM CONFIGURATION
# =============================================================================
# This is the root module that orchestrates all SIEM components.
# 
# ARCHITECTURE OVERVIEW:
# ----------------------
# 1. CloudTrail -> S3 -> EventBridge -> Kinesis Firehose -> OpenSearch
# 2. GuardDuty -> EventBridge -> Lambda Normalizer -> Kinesis -> OpenSearch  
# 3. VPC Flow Logs -> CloudWatch -> Lambda -> Kinesis -> OpenSearch
# 4. Security Hub -> EventBridge -> Lambda -> Kinesis -> OpenSearch
#
# COST OPTIMIZATION:
# - Uses LocalStack for local development/testing
# - Minimal instance sizes for non-production
# - S3 Intelligent-Tiering for log storage
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  
  # Backend configuration - uncomment for production
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "siem-pipeline/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# -----------------------------------------------------------------------------
# LOCAL VARIABLES
# -----------------------------------------------------------------------------
# These locals centralize naming conventions and common tags
# -----------------------------------------------------------------------------
locals {
  # Naming prefix for all resources
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to ALL resources for cost tracking and organization
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner_email
    CostCenter  = "SIEM-Pipeline"
    CreatedAt   = timestamp()
  }
  
  # Feature flags for conditional resource creation
  enable_guardduty     = var.enable_guardduty && !var.use_localstack
  enable_cloudtrail    = var.enable_cloudtrail && !var.use_localstack
  enable_securityhub   = var.enable_securityhub && !var.use_localstack
  enable_macie         = var.enable_macie && !var.use_localstack
}

# -----------------------------------------------------------------------------
# DATA SOURCES
# -----------------------------------------------------------------------------
# Fetch existing AWS account information
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# -----------------------------------------------------------------------------
# RANDOM SUFFIX FOR UNIQUE NAMING
# -----------------------------------------------------------------------------
# S3 buckets require globally unique names - this adds randomness
# -----------------------------------------------------------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# -----------------------------------------------------------------------------
# MODULE: S3 LOG ARCHIVE
# -----------------------------------------------------------------------------
# Central storage for all security logs with intelligent tiering
# -----------------------------------------------------------------------------
module "s3_log_archive" {
  source = "./modules/s3-log-archive"
  
  name_prefix         = local.name_prefix
  random_suffix       = random_id.suffix.hex
  retention_days      = var.log_retention_days
  enable_versioning   = var.environment == "prod"
  enable_replication  = var.enable_cross_region_replication
  replication_region  = var.replication_region
  kms_key_arn         = module.kms.key_arn
  
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# MODULE: KMS ENCRYPTION
# -----------------------------------------------------------------------------
# Customer-managed keys for encrypting all SIEM data at rest
# -----------------------------------------------------------------------------
module "kms" {
  source = "./modules/kms"
  
  name_prefix     = local.name_prefix
  environment     = var.environment
  admin_role_arns = var.kms_admin_role_arns
  
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# MODULE: CLOUDTRAIL
# -----------------------------------------------------------------------------
# Captures ALL AWS API activity for audit and security analysis
# -----------------------------------------------------------------------------
module "cloudtrail" {
  source = "./modules/cloudtrail"
  count  = local.enable_cloudtrail ? 1 : 0
  
  name_prefix           = local.name_prefix
  s3_bucket_name        = module.s3_log_archive.bucket_name
  s3_bucket_arn         = module.s3_log_archive.bucket_arn
  kms_key_arn           = module.kms.key_arn
  enable_log_validation = true
  is_multi_region       = var.cloudtrail_multi_region
  
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# MODULE: KINESIS FIREHOSE
# -----------------------------------------------------------------------------
# Real-time data streaming to OpenSearch with buffering
# -----------------------------------------------------------------------------
module "kinesis_firehose" {
  source = "./modules/kinesis-firehose"
  
  name_prefix              = local.name_prefix
  opensearch_domain_arn    = module.opensearch.domain_arn
  opensearch_endpoint      = module.opensearch.endpoint
  s3_backup_bucket_arn     = module.s3_log_archive.bucket_arn
  kms_key_arn              = module.kms.key_arn
  buffer_size_mb           = var.firehose_buffer_size
  buffer_interval_seconds  = var.firehose_buffer_interval
  
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# MODULE: OPENSEARCH
# -----------------------------------------------------------------------------
# Central SIEM dashboard and search engine for security analytics
# -----------------------------------------------------------------------------
module "opensearch" {
  source = "./modules/opensearch"
  
  name_prefix            = local.name_prefix
  instance_type          = var.opensearch_instance_type
  instance_count         = var.opensearch_instance_count
  ebs_volume_size        = var.opensearch_ebs_size
  engine_version         = var.opensearch_version
  kms_key_arn            = module.kms.key_arn
  vpc_id                 = var.vpc_id
  subnet_ids             = var.private_subnet_ids
  allowed_cidr_blocks    = var.opensearch_allowed_cidrs
  master_user_name       = var.opensearch_master_user
  master_user_password   = var.opensearch_master_password
  
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# MODULE: EVENTBRIDGE
# -----------------------------------------------------------------------------
# Event routing from AWS security services to processing pipelines
# -----------------------------------------------------------------------------
module "eventbridge" {
  source = "./modules/eventbridge"
  
  name_prefix              = local.name_prefix
  guardduty_lambda_arn     = module.lambda_normalizers.guardduty_normalizer_arn
  securityhub_lambda_arn   = module.lambda_normalizers.securityhub_normalizer_arn
  cloudtrail_lambda_arn    = module.lambda_normalizers.cloudtrail_normalizer_arn
  enable_guardduty_rule    = local.enable_guardduty
  enable_securityhub_rule  = local.enable_securityhub
  enable_cloudtrail_rule   = local.enable_cloudtrail
  
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# MODULE: LAMBDA NORMALIZERS
# -----------------------------------------------------------------------------
# Serverless functions that normalize diverse security event formats
# -----------------------------------------------------------------------------
module "lambda_normalizers" {
  source = "./modules/lambda-normalizers"
  
  name_prefix             = local.name_prefix
  kinesis_stream_arn      = module.kinesis_firehose.delivery_stream_arn
  kinesis_stream_name     = module.kinesis_firehose.delivery_stream_name
  kms_key_arn             = module.kms.key_arn
  lambda_runtime          = "python3.11"
  lambda_timeout          = 60
  lambda_memory           = 256
  
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# OUTPUTS - Exported values for reference
# -----------------------------------------------------------------------------
output "siem_dashboard_url" {
  description = "URL to access the OpenSearch SIEM dashboard"
  value       = "https://${module.opensearch.endpoint}/_dashboards"
}

output "s3_log_bucket" {
  description = "S3 bucket for centralized log storage"
  value       = module.s3_log_archive.bucket_name
}

output "kinesis_stream_name" {
  description = "Kinesis Firehose delivery stream name"
  value       = module.kinesis_firehose.delivery_stream_name
}
