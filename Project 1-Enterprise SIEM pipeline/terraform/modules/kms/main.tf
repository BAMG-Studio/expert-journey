# =============================================================================
# KMS MODULE - Customer Managed Encryption Keys
# =============================================================================
# This module creates KMS keys for encrypting all SIEM data at rest.
# 
# KEY FEATURES:
# - Automatic key rotation every year
# - Multi-region key for disaster recovery
# - Separate key policies for admin vs usage
# =============================================================================

resource "aws_kms_key" "siem_master_key" {
  description             = "${var.name_prefix} - Master encryption key for SIEM data"
  deletion_window_in_days = var.environment == "prod" ? 30 : 7
  enable_key_rotation     = true
  multi_region            = var.environment == "prod"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowServiceUsage"
        Effect = "Allow"
        Principal = {
          Service = [
            "s3.amazonaws.com",
            "kinesis.amazonaws.com",
            "firehose.amazonaws.com",
            "es.amazonaws.com",
            "logs.amazonaws.com",
            "lambda.amazonaws.com",
            "cloudtrail.amazonaws.com"
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-siem-master-key"
  })
}

resource "aws_kms_alias" "siem_master_key" {
  name          = "alias/${var.name_prefix}-siem"
  target_key_id = aws_kms_key.siem_master_key.key_id
}

data "aws_caller_identity" "current" {}
