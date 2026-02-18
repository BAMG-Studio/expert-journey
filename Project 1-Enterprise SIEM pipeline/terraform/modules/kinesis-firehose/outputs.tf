output "delivery_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.siem.arn
}
output "delivery_stream_name" {
  value = aws_kinesis_firehose_delivery_stream.siem.name
}
output "firehose_role_arn" {
  value = aws_iam_role.firehose.arn
}
