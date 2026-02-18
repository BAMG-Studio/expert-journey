variable "name_prefix" { type = string }
variable "instance_type" { type = string; default = "t3.small.search" }
variable "instance_count" { type = number; default = 1 }
variable "ebs_volume_size" { type = number; default = 20 }
variable "engine_version" { type = string; default = "OpenSearch_2.11" }
variable "kms_key_arn" { type = string }
variable "vpc_id" { type = string; default = "" }
variable "subnet_ids" { type = list(string); default = [] }
variable "allowed_cidr_blocks" { type = list(string); default = ["10.0.0.0/8"] }
variable "master_user_name" { type = string; default = "admin"; sensitive = true }
variable "master_user_password" { type = string; sensitive = true }
variable "tags" { type = map(string); default = {} }
