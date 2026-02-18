# =============================================================================
# OPENSEARCH MODULE - SIEM Dashboard and Search Engine
# =============================================================================
# Amazon OpenSearch Service provides the search and visualization layer.
# This is where security analysts will investigate and correlate events.
#
# COMPONENTS:
# - OpenSearch Domain (search engine)
# - OpenSearch Dashboards (visualization UI)
# - Fine-grained access control
# - VPC deployment for security
# =============================================================================

resource "aws_opensearch_domain" "siem" {
  domain_name    = "${var.name_prefix}-siem"
  engine_version = var.engine_version
  
  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    zone_awareness_enabled   = var.instance_count > 1
    dedicated_master_enabled = var.instance_count >= 3
    
    dynamic "zone_awareness_config" {
      for_each = var.instance_count > 1 ? [1] : []
      content {
        availability_zone_count = min(var.instance_count, 3)
      }
    }
  }
  
  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.ebs_volume_size
    iops        = 3000
    throughput  = 125
  }
  
  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_arn
  }
  
  node_to_node_encryption {
    enabled = true
  }
  
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }
  
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action    = "es:*"
        Resource  = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.name_prefix}-siem/*"
      }
    ]
  })
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-opensearch-siem"
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
