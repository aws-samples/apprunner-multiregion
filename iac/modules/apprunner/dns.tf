variable "route53_zone" {
  description = "A route53 zone to host the app runner custom domain name"
  type        = string
}

variable "app_sub_domain" {
  description = "The app sub domain"
  type        = string
}

# lookup route53 zone
data "aws_route53_zone" "main" {
  name = var.route53_zone
}

resource "aws_apprunner_custom_domain_association" "main" {
  domain_name = "${var.app_sub_domain}.${data.aws_route53_zone.main.name}"
  service_arn = aws_apprunner_service.main.arn
}

# route 50% of the requests to the shared multi-region endpoint to the regional endpoint
resource "aws_route53_record" "weighted" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = aws_apprunner_custom_domain_association.main.domain_name
  records         = [aws_apprunner_service.main.service_url]
  set_identifier  = var.region
  type            = "CNAME"
  ttl             = 5
  health_check_id = aws_route53_health_check.main.id

  weighted_routing_policy {
    weight = 128
  }
}

resource "aws_route53_health_check" "main" {
  fqdn              = aws_apprunner_service.main.service_url
  resource_path     = var.health_check
  type              = "HTTPS"
  port              = 443
  failure_threshold = 5
  request_interval  = 30

  tags = {
    Name = "${var.app}-${var.region}"
  }
}

# validate app runner custom domain in this region
# workaround for https://github.com/hashicorp/terraform-provider-aws/issues/23460

locals {
  validation_records = tolist(aws_apprunner_custom_domain_association.main.certificate_validation_records)
  ttl                = 60
  allow_overwrite    = true
}

resource "aws_route53_record" "validation_0" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = local.validation_records[0].name
  type            = local.validation_records[0].type
  records         = [local.validation_records[0].value]
  ttl             = local.ttl
  allow_overwrite = local.allow_overwrite
}

resource "aws_route53_record" "validation_1" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = local.validation_records[1].name
  type            = local.validation_records[1].type
  records         = [local.validation_records[1].value]
  ttl             = local.ttl
  allow_overwrite = local.allow_overwrite
}

resource "aws_route53_record" "validation_2" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = local.validation_records[2].name
  type            = local.validation_records[2].type
  records         = [local.validation_records[2].value]
  ttl             = local.ttl
  allow_overwrite = local.allow_overwrite
}

# outputs

# Note that the App Runner custom domain validation can take up to 24-48 hours to become active
output "custom_service_url" {
  description = "the multi-region endpoint"
  value       = "https://${aws_apprunner_custom_domain_association.main.domain_name}"
}

