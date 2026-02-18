# =============================================================================
# ENTERPRISE SIEM PIPELINE - TERRAFORM VARIABLES
# =============================================================================
# This file defines ALL configurable parameters for the SIEM pipeline.
# 
# VARIABLE CATEGORIES:
# 1. Project Configuration - Names, environment, ownership
# 2. Feature Flags - Enable/disable specific AWS services
# 3. Networking - VPC, subnets, security groups
# 4. OpenSearch - SIEM search engine configuration
# 5. Kinesis - Data streaming configuration
# 6. Lambda - Serverless function settings
# 7. Storage - S3 retention and replication
# 8. Cost Optimization - LocalStack integration
# =============================================================================

# -----------------------------------------------------------------------------
# PROJECT CONFIGURATION
# -----------------------------------------------------------------------------
# These variables establish naming conventions and metadata
# -----------------------------------------------------------------------------

variable "project_name" {
  description = <<-EOT
    Name of the project used for resource naming.
    This becomes a prefix for ALL resources created.
    Example: If project_name = 'siem', resources will be named 'siem-dev-bucket'
  EOT
  type        = string
  default     = "enterprise-siem"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = <<-EOT
    Deployment environment (dev/staging/prod).
    Controls resource sizing and feature enablement:
    - dev: Minimal resources, LocalStack enabled
    - staging: Medium resources, real AWS services
    - prod: Full resources, all security features enabled
  EOT
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "Primary AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "owner_email" {
  description = "Email of the resource owner for tagging and notifications"
  type        = string
  default     = "devops@example.com"
}

# -----------------------------------------------------------------------------
# FEATURE FLAGS
# -----------------------------------------------------------------------------
# Toggle AWS security services on/off
# COST TIP: Disable services in dev to minimize costs
# -----------------------------------------------------------------------------

variable "enable_guardduty" {
  description = <<-EOT
    Enable AWS GuardDuty threat detection.
    GuardDuty analyzes VPC Flow Logs, CloudTrail, and DNS logs
    to detect malicious activity and unauthorized behavior.
    COST: ~$4/GB of data analyzed
  EOT
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = <<-EOT
    Enable AWS CloudTrail for API activity logging.
    Records ALL AWS API calls for your account.
    COST: First trail free, $2/100K events for additional trails
  EOT
  type        = bool
  default     = true
}

variable "enable_securityhub" {
  description = <<-EOT
    Enable AWS Security Hub for centralized security findings.
    Aggregates findings from GuardDuty, Inspector, Macie, etc.
    COST: $0.0010 per finding ingested
  EOT
  type        = bool
  default     = true
}

variable "enable_macie" {
  description = <<-EOT
    Enable AWS Macie for S3 data classification.
    Uses ML to discover and protect sensitive data in S3.
    COST: $1/GB scanned (first 1GB free/month)
  EOT
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic analysis"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# COST OPTIMIZATION - LOCALSTACK
# -----------------------------------------------------------------------------
# Use LocalStack for local development to avoid AWS costs
# -----------------------------------------------------------------------------

variable "use_localstack" {
  description = <<-EOT
    Use LocalStack instead of real AWS services.
    When enabled, the provider endpoints point to LocalStack.
    This allows full SIEM testing without any AWS costs.
    
    To start LocalStack: docker-compose up -d localstack
  EOT
  type        = bool
  default     = false
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}

# -----------------------------------------------------------------------------
# NETWORKING CONFIGURATION
# -----------------------------------------------------------------------------
# VPC and subnet configuration for OpenSearch and Lambda
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = <<-EOT
    VPC ID where OpenSearch and Lambda will be deployed.
    For LocalStack testing, this can be any valid VPC format.
    In production, use an existing VPC with private subnets.
  EOT
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = <<-EOT
    List of private subnet IDs for OpenSearch cluster.
    OpenSearch requires at least 2 subnets in different AZs
    for production deployments with zone awareness.
  EOT
  type        = list(string)
  default     = []
}

variable "opensearch_allowed_cidrs" {
  description = "CIDR blocks allowed to access OpenSearch"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# -----------------------------------------------------------------------------
# OPENSEARCH CONFIGURATION
# -----------------------------------------------------------------------------
# Amazon OpenSearch Service (formerly Elasticsearch) settings
# This is the SIEM dashboard and search engine
# -----------------------------------------------------------------------------

variable "opensearch_instance_type" {
  description = <<-EOT
    OpenSearch instance type.
    Sizing guide:
    - t3.small.search: Dev/testing (2 vCPU, 2GB RAM) - ~$0.036/hr
    - r6g.large.search: Small prod (2 vCPU, 16GB RAM) - ~$0.167/hr  
    - r6g.xlarge.search: Medium prod (4 vCPU, 32GB RAM) - ~$0.335/hr
  EOT
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_instance_count" {
  description = <<-EOT
    Number of OpenSearch data nodes.
    - 1 node: Dev/testing only (no HA)
    - 2 nodes: Minimum for production (zone awareness)
    - 3+ nodes: High availability with dedicated masters
  EOT
  type        = number
  default     = 1
  
  validation {
    condition     = var.opensearch_instance_count >= 1 && var.opensearch_instance_count <= 80
    error_message = "Instance count must be between 1 and 80."
  }
}

variable "opensearch_ebs_size" {
  description = <<-EOT
    EBS volume size in GB per OpenSearch node.
    Calculate based on: daily_log_volume * retention_days * 1.1 (10% overhead)
    Example: 10GB/day * 30 days * 1.1 = 330GB
  EOT
  type        = number
  default     = 20
  
  validation {
    condition     = var.opensearch_ebs_size >= 10 && var.opensearch_ebs_size <= 16384
    error_message = "EBS size must be between 10GB and 16TB."
  }
}

variable "opensearch_version" {
  description = "OpenSearch engine version"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "opensearch_master_user" {
  description = "Master username for OpenSearch internal database"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "opensearch_master_password" {
  description = <<-EOT
    Master password for OpenSearch.
    REQUIREMENTS:
    - At least 8 characters
    - At least one uppercase letter
    - At least one lowercase letter
    - At least one number
    - At least one special character
  EOT
  type        = string
  sensitive   = true
  default     = ""
  
  validation {
    condition = (
      var.opensearch_master_password == "" ||
      can(regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$", var.opensearch_master_password))
    )
    error_message = "Password must contain uppercase, lowercase, number, and special character."
  }
}

# -----------------------------------------------------------------------------
# KINESIS FIREHOSE CONFIGURATION
# -----------------------------------------------------------------------------
# Real-time data delivery stream settings
# -----------------------------------------------------------------------------

variable "firehose_buffer_size" {
  description = <<-EOT
    Buffer size in MB before Firehose delivers to OpenSearch.
    - Lower values (1-5MB): Near real-time delivery, higher costs
    - Higher values (64-128MB): Batch delivery, lower costs
    Recommended: 5MB for security events (timely detection)
  EOT
  type        = number
  default     = 5
  
  validation {
    condition     = var.firehose_buffer_size >= 1 && var.firehose_buffer_size <= 128
    error_message = "Buffer size must be between 1MB and 128MB."
  }
}

variable "firehose_buffer_interval" {
  description = <<-EOT
    Buffer interval in seconds before Firehose delivers.
    Delivery occurs when EITHER buffer size OR interval is reached.
    - 60 seconds: Near real-time
    - 300 seconds: Cost-optimized batching
  EOT
  type        = number
  default     = 60
  
  validation {
    condition     = var.firehose_buffer_interval >= 60 && var.firehose_buffer_interval <= 900
    error_message = "Buffer interval must be between 60 and 900 seconds."
  }
}

# -----------------------------------------------------------------------------
# STORAGE CONFIGURATION
# -----------------------------------------------------------------------------
# S3 log archive settings
# -----------------------------------------------------------------------------

variable "log_retention_days" {
  description = <<-EOT
    Days to retain logs in S3 before deletion.
    Compliance requirements:
    - SOC 2: 1 year (365 days)
    - PCI DSS: 1 year (365 days)
    - HIPAA: 6 years (2190 days)
    - Default: 90 days for cost optimization
  EOT
  type        = number
  default     = 90
}

variable "enable_cross_region_replication" {
  description = "Enable S3 cross-region replication for disaster recovery"
  type        = bool
  default     = false
}

variable "replication_region" {
  description = "Target region for S3 replication"
  type        = string
  default     = "us-west-2"
}

# -----------------------------------------------------------------------------
# KMS ENCRYPTION
# -----------------------------------------------------------------------------
variable "kms_admin_role_arns" {
  description = "ARNs of IAM roles that can administer the KMS key"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# CLOUDTRAIL CONFIGURATION
# -----------------------------------------------------------------------------
variable "cloudtrail_multi_region" {
  description = "Enable multi-region CloudTrail logging"
  type        = bool
  default     = true
}
