variable "name_prefix" { type = string }
variable "opensearch_domain_arn" { type = string }
variable "opensearch_endpoint" { type = string }
variable "s3_backup_bucket_arn" { type = string }
variable "kms_key_arn" { type = string }
variable "buffer_size_mb" { type = number; default = 5 }
variable "buffer_interval_seconds" { type = number; default = 60 }
variable "tags" { type = map(string); default = {} }
