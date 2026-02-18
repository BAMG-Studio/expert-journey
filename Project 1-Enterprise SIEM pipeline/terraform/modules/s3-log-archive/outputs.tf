output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.log_archive.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.log_archive.arn
}

output "bucket_domain_name" {
  description = "Domain name of the bucket"
  value       = aws_s3_bucket.log_archive.bucket_domain_name
}
