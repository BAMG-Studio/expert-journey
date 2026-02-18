variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "random_suffix" {
  description = "Random suffix for globally unique bucket name"
  type        = string
}

variable "retention_days" {
  description = "Days to retain logs before deletion"
  type        = number
  default     = 90
}

variable "enable_versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = false
}

variable "replication_region" {
  description = "Target region for replication"
  type        = string
  default     = "us-west-2"
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
