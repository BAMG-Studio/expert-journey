# =============================================================================
# Outputs for Enterprise SIEM Pipeline
# =============================================================================

output "kms_key_arn" {
  description = "KMS key ARN for SIEM encryption"
  value       = module.kms.kms_key_arn
}

output "s3_log_bucket" {
  description = "S3 bucket for log archival"
  value       = module.s3_log_archive.bucket_name
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN"
  value       = module.cloudtrail.trail_arn
}

output "opensearch_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = module.opensearch.domain_endpoint
}

output "opensearch_dashboard" {
  description = "OpenSearch Dashboards URL"
  value       = "https://${module.opensearch.kibana_endpoint}/_dashboards"
}

output "firehose_arn" {
  description = "Kinesis Firehose delivery stream ARN"
  value       = module.kinesis_firehose.firehose_arn
}

output "lambda_normalizers" {
  description = "Lambda normalizer function ARNs"
  value       = module.lambda_normalizers.lambda_arns
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
