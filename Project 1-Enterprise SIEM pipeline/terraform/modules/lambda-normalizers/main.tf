# =============================================================================
# LAMBDA NORMALIZERS MODULE - Security Event Processing
# =============================================================================
# This module deploys Lambda functions that normalize security events
# from various AWS sources into a common NIST AU-3 compliant schema.
# =============================================================================

# ---------------------------------------------------------------------------
# IAM Role for Lambda Functions
# ---------------------------------------------------------------------------
resource "aws_iam_role" "normalizer" {
  name = "${var.name_prefix}-normalizer-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "normalizer" {
  name = "${var.name_prefix}-normalizer-policy"
  role = aws_iam_role.normalizer.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = ["firehose:PutRecord", "firehose:PutRecordBatch"]
        Resource = var.kinesis_stream_arn
      },
      {
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = var.kms_key_arn
      },
      {
        Effect = "Allow"
        Action = ["organizations:DescribeAccount", "organizations:ListAccounts"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["resourcegroupstaggingapi:GetResources"]
        Resource = "*"
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# GuardDuty Normalizer Lambda
# ---------------------------------------------------------------------------
data "archive_file" "guardduty" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/normalizers/guardduty_normalizer.py"
  output_path = "${path.module}/builds/guardduty_normalizer.zip"
}

resource "aws_lambda_function" "guardduty" {
  function_name    = "${var.name_prefix}-guardduty-normalizer"
  role             = aws_iam_role.normalizer.arn
  handler          = "guardduty_normalizer.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory
  filename         = data.archive_file.guardduty.output_path
  source_code_hash = data.archive_file.guardduty.output_base64sha256
  
  environment {
    variables = {
      FIREHOSE_STREAM_NAME = var.kinesis_stream_name
      LOG_LEVEL            = "INFO"
    }
  }
  tags = var.tags
}

# ---------------------------------------------------------------------------
# CloudTrail Normalizer Lambda
# ---------------------------------------------------------------------------
data "archive_file" "cloudtrail" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/normalizers/cloudtrail_normalizer.py"
  output_path = "${path.module}/builds/cloudtrail_normalizer.zip"
}

resource "aws_lambda_function" "cloudtrail" {
  function_name    = "${var.name_prefix}-cloudtrail-normalizer"
  role             = aws_iam_role.normalizer.arn
  handler          = "cloudtrail_normalizer.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory
  filename         = data.archive_file.cloudtrail.output_path
  source_code_hash = data.archive_file.cloudtrail.output_base64sha256
  
  environment {
    variables = {
      FIREHOSE_STREAM_NAME = var.kinesis_stream_name
      LOG_LEVEL            = "INFO"
    }
  }
  tags = var.tags
}

# ---------------------------------------------------------------------------
# Security Hub Normalizer Lambda
# ---------------------------------------------------------------------------
data "archive_file" "securityhub" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/normalizers/securityhub_normalizer.py"
  output_path = "${path.module}/builds/securityhub_normalizer.zip"
}

resource "aws_lambda_function" "securityhub" {
  function_name    = "${var.name_prefix}-securityhub-normalizer"
  role             = aws_iam_role.normalizer.arn
  handler          = "securityhub_normalizer.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory
  filename         = data.archive_file.securityhub.output_path
  source_code_hash = data.archive_file.securityhub.output_base64sha256
  
  environment {
    variables = {
      FIREHOSE_STREAM_NAME = var.kinesis_stream_name
      LOG_LEVEL            = "INFO"
    }
  }
  tags = var.tags
}
