# =============================================================================
# TERRAFORM PROVIDERS CONFIGURATION
# =============================================================================
# This file configures the AWS provider with support for both:
# 1. Real AWS deployment (production)
# 2. LocalStack for local development/testing (cost-free)
#
# LOCALSTACK USAGE:
# -----------------
# Set use_localstack = true in your terraform.tfvars
# Start LocalStack: docker-compose up -d localstack
# Run: terraform apply
# =============================================================================

# -----------------------------------------------------------------------------
# AWS PROVIDER - MAIN REGION
# -----------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
  
  # LocalStack configuration - these are ignored when use_localstack = false
  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      # LocalStack endpoints for each AWS service
      s3             = var.localstack_endpoint
      kinesis        = var.localstack_endpoint
      firehose       = var.localstack_endpoint
      opensearch     = var.localstack_endpoint
      lambda         = var.localstack_endpoint
      iam            = var.localstack_endpoint
      sts            = var.localstack_endpoint
      cloudtrail     = var.localstack_endpoint
      cloudwatch     = var.localstack_endpoint
      events         = var.localstack_endpoint
      kms            = var.localstack_endpoint
      logs           = var.localstack_endpoint
      sns            = var.localstack_endpoint
      sqs            = var.localstack_endpoint
    }
  }
  
  # Skip credential validation when using LocalStack
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack
  
  # LocalStack uses dummy credentials
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# -----------------------------------------------------------------------------
# AWS PROVIDER - REPLICATION REGION (for S3 cross-region replication)
# -----------------------------------------------------------------------------
provider "aws" {
  alias  = "replication"
  region = var.replication_region
  
  # Same LocalStack handling for replication region
  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      s3  = var.localstack_endpoint
      kms = var.localstack_endpoint
    }
  }
  
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack
  
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null
}
