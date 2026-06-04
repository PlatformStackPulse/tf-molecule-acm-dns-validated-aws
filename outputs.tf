output "certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = module.certificate.arn
}

output "domain_name" {
  description = "Primary domain name of the certificate"
  value       = module.certificate.domain_name
}
