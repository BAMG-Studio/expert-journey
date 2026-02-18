# =============================================================================
# S3 LOG ARCHIVE MODULE - Centralized Security Log Storage
# =============================================================================
# This module creates S3 buckets for storing all SIEM security logs.
#
# FEATURES:
# - Server-side encryption with KMS
# - Lifecycle policies for cost optimization
# - Versioning for compliance
# - Access logging for audit trails
# - Cross-region replication (optional)
# =============================================================================

resource "aws_s3_bucket" "log_archive" {
  bucket        = "${var.name_prefix}-logs-${var.random_suffix}"
  force_destroy = var.environment != "prod"
  
  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-log-archive"
    Purpose = "SIEM Security Log Archive"
  })
}

# Enable versioning for compliance
resource "aws_s3_bucket_versioning" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Server-side encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true  # Reduces KMS costs by 99%
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "log_archive" {
  bucket                  = aws_s3_bucket.log_archive.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rules for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id
  
  rule {
    id     = "transition-to-intelligent-tiering"
    status = "Enabled"
    
    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }
  
  rule {
    id     = "transition-to-glacier"
    status = "Enabled"
    
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
  
  rule {
    id     = "expire-old-logs"
    status = "Enabled"
    
    expiration {
      days = var.retention_days
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Bucket policy for CloudTrail and other services
resource "aws_s3_bucket_policy" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.log_archive.arn}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      },
      {
        Sid       = "AllowCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.log_archive.arn
      },
      {
        Sid       = "AllowFirehoseWrite"
        Effect    = "Allow"
        Principal = { Service = "firehose.amazonaws.com" }
        Action    = ["s3:PutObject", "s3:PutObjectAcl"]
        Resource  = "${aws_s3_bucket.log_archive.arn}/*"
      }
    ]
  })
}
