output "vpc_id" { value = aws_vpc.siem.id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "opensearch_sg_id" { value = aws_security_group.opensearch.id }
