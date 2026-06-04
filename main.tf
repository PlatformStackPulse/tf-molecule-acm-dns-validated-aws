# Molecule: ACM Certificate with Route53 DNS Validation

module "certificate" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-acm-certificate-aws.git?ref=dc91ea5923b27260af6a0e6836bd324700af30db"

  context                   = module.this.context
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
}

module "validation_records" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-route53-record-aws.git?ref=e83e2ca88dc9d9681a321785b6cf623d81cca814"

  for_each = {
    for dvo in module.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  context = module.this.context
  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  depends_on = [module.certificate]
}

module "validation" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-acm-certificate-validation-aws.git?ref=201599f62316f65f6ca464552ee14331a1f219cd"

  context                 = module.this.context
  certificate_arn         = module.certificate.arn
  validation_record_fqdns = [for record in module.validation_records : record.fqdn]

  depends_on = [module.validation_records]
}
