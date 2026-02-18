variable "name_prefix" { type = string }
variable "s3_bucket_name" { type = string }
variable "s3_bucket_arn" { type = string }
variable "kms_key_arn" { type = string }
variable "enable_log_validation" { type = bool; default = true }
variable "is_multi_region" { type = bool; default = true }
variable "tags" { type = map(string); default = {} }
