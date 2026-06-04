output "certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = try(aws_acm_certificate_validation.this[0].certificate_arn, "")
}

output "domain_name" {
  description = "Primary domain name of the certificate"
  value       = try(aws_acm_certificate.this[0].domain_name, "")
}
