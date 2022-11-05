output "public_subnet_id" {
  value = aws_subnet.prod-public.id
}
output "private_subnet_id" {
  value = aws_subnet.prod-private.id
}
output "public1_subnet_id" {
  value = aws_subnet.prodpublic_1.id
}
output "private1_subnet_id" {
  value = aws_subnet.prodprivate_1.id
}
output "vpc_id" {
  value = aws_vpc.prodvpc.id
}
output "cidr" {
  value = aws_vpc.prodvpc.cidr_block
}
output "security_group_id" {
  value = aws_security_group.allow_tls.id
}
output "s3_bukcet_arn" {
  value = aws_s3_bucket.elb-bucket.arn
}

