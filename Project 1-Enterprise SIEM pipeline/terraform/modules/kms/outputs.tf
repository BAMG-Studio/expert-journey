output "key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.siem_master_key.arn
}

output "key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.siem_master_key.key_id
}

output "alias_name" {
  description = "Alias name of the KMS key"
  value       = aws_kms_alias.siem_master_key.name
}
