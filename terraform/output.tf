output "app_dns" {
  value = aws_route53_record.app_cname_record.name
}
