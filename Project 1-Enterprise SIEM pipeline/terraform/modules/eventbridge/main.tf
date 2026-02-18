# =============================================================================
# EVENTBRIDGE MODULE - Security Event Routing
# =============================================================================
# EventBridge routes security events from AWS services to Lambda normalizers.
#
# SUPPORTED SOURCES:
# - GuardDuty findings (threat detection)
# - Security Hub findings (aggregated security)
# - CloudTrail events (API activity)
# =============================================================================

resource "aws_cloudwatch_event_rule" "guardduty" {
  count       = var.enable_guardduty_rule ? 1 : 0
  name        = "${var.name_prefix}-guardduty-events"
  description = "Capture GuardDuty findings for SIEM processing"
  
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
  
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "guardduty" {
  count     = var.enable_guardduty_rule ? 1 : 0
  rule      = aws_cloudwatch_event_rule.guardduty[0].name
  target_id = "guardduty-lambda"
  arn       = var.guardduty_lambda_arn
}

resource "aws_lambda_permission" "guardduty" {
  count         = var.enable_guardduty_rule ? 1 : 0
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.guardduty_lambda_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty[0].arn
}

resource "aws_cloudwatch_event_rule" "securityhub" {
  count       = var.enable_securityhub_rule ? 1 : 0
  name        = "${var.name_prefix}-securityhub-events"
  description = "Capture Security Hub findings for SIEM processing"
  
  event_pattern = jsonencode({
    source      = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
  })
  
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "securityhub" {
  count     = var.enable_securityhub_rule ? 1 : 0
  rule      = aws_cloudwatch_event_rule.securityhub[0].name
  target_id = "securityhub-lambda"
  arn       = var.securityhub_lambda_arn
}

resource "aws_lambda_permission" "securityhub" {
  count         = var.enable_securityhub_rule ? 1 : 0
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.securityhub_lambda_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.securityhub[0].arn
}
