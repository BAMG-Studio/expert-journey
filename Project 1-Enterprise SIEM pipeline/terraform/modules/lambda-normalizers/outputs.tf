output "guardduty_normalizer_arn" {
  value = aws_lambda_function.guardduty.arn
}
output "cloudtrail_normalizer_arn" {
  value = aws_lambda_function.cloudtrail.arn
}
output "securityhub_normalizer_arn" {
  value = aws_lambda_function.securityhub.arn
}
output "normalizer_role_arn" {
  value = aws_iam_role.normalizer.arn
}
