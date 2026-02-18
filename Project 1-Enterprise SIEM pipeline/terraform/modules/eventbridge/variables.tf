variable "name_prefix" { type = string }
variable "guardduty_lambda_arn" { type = string }
variable "securityhub_lambda_arn" { type = string }
variable "cloudtrail_lambda_arn" { type = string }
variable "enable_guardduty_rule" { type = bool; default = true }
variable "enable_securityhub_rule" { type = bool; default = true }
variable "enable_cloudtrail_rule" { type = bool; default = true }
variable "tags" { type = map(string); default = {} }
