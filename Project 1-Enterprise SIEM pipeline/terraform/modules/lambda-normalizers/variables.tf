variable "name_prefix" { type = string }
variable "kinesis_stream_arn" { type = string }
variable "kinesis_stream_name" { type = string }
variable "kms_key_arn" { type = string }
variable "lambda_runtime" { type = string; default = "python3.11" }
variable "lambda_timeout" { type = number; default = 60 }
variable "lambda_memory" { type = number; default = 256 }
variable "tags" { type = map(string); default = {} }
