# =============================================================================
# KINESIS FIREHOSE MODULE - Real-time Data Streaming
# =============================================================================
# Kinesis Firehose delivers security events to OpenSearch in near real-time.
#
# DATA FLOW:
# Lambda Normalizer -> Kinesis Firehose -> OpenSearch (primary)
#                                      -> S3 (backup for failed records)
# =============================================================================

resource "aws_kinesis_firehose_delivery_stream" "siem" {
  name        = "${var.name_prefix}-siem-stream"
  destination = "opensearch"
  
  opensearch_configuration {
    domain_arn            = var.opensearch_domain_arn
    role_arn              = aws_iam_role.firehose.arn
    index_name            = "security-events"
    index_rotation_period = "OneDay"
    buffering_interval    = var.buffer_interval_seconds
    buffering_size        = var.buffer_size_mb
    retry_duration        = 60
    
    s3_configuration {
      role_arn           = aws_iam_role.firehose.arn
      bucket_arn         = var.s3_backup_bucket_arn
      prefix             = "firehose-failed/"
      buffering_interval = 60
      buffering_size     = 5
      compression_format = "GZIP"
    }
    
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = "delivery"
    }
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-firehose"
  })
}

resource "aws_cloudwatch_log_group" "firehose" {
  name              = "/aws/firehose/${var.name_prefix}-siem"
  retention_in_days = 7
}

resource "aws_iam_role" "firehose" {
  name = "${var.name_prefix}-firehose-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "firehose.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "firehose" {
  name = "${var.name_prefix}-firehose-policy"
  role = aws_iam_role.firehose.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["es:ESHttpPost", "es:ESHttpPut", "es:DescribeElasticsearchDomain*"]
        Resource = [var.opensearch_domain_arn, "${var.opensearch_domain_arn}/*"]
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
        Resource = [var.s3_backup_bucket_arn, "${var.s3_backup_bucket_arn}/*"]
      },
      {
        Effect = "Allow"
        Action = ["logs:PutLogEvents", "logs:CreateLogStream"]
        Resource = "${aws_cloudwatch_log_group.firehose.arn}:*"
      },
      {
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = var.kms_key_arn
      }
    ]
  })
}
