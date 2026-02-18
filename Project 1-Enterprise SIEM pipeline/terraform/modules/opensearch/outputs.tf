output "domain_arn" {
  value = aws_opensearch_domain.siem.arn
}
output "endpoint" {
  value = aws_opensearch_domain.siem.endpoint
}
output "dashboard_url" {
  value = "https://${aws_opensearch_domain.siem.endpoint}/_dashboards"
}
output "domain_name" {
  value = aws_opensearch_domain.siem.domain_name
}
