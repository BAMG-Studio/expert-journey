output "guardduty_rule_arn" {
  value = length(aws_cloudwatch_event_rule.guardduty) > 0 ? aws_cloudwatch_event_rule.guardduty[0].arn : ""
}
output "securityhub_rule_arn" {
  value = length(aws_cloudwatch_event_rule.securityhub) > 0 ? aws_cloudwatch_event_rule.securityhub[0].arn : ""
}
