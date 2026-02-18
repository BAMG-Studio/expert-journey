# =============================================================================
# CLOUDTRAIL MODULE - AWS API Activity Logging
# =============================================================================
# CloudTrail captures ALL AWS API calls for security auditing.
# This is the foundation of AWS security monitoring.
# =============================================================================

resource "aws_cloudtrail" "siem" {
  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = var.s3_bucket_name
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = var.is_multi_region
  enable_log_file_validation    = var.enable_log_validation
  kms_key_id                    = var.kms_key_arn
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }
  
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cloudtrail"
  })
}
