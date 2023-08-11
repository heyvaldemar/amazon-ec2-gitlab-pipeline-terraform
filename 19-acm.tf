
# Request a new AWS Certificate Manager (ACM) certificate for the specified domain
resource "aws_acm_certificate" "acm_1_certificate" {
  domain_name       = var.acm_1_certificate_1_domain_name
  validation_method = "DNS"

  # Lifecycle settings to manage the certificate's lifecycle
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "certificate-gitlab-1"
  }
}

# Creates a Route 53 DNS validation record for the ACM certificate
resource "aws_route53_record" "acm_1_certificate_validation_record" {
  zone_id = data.aws_route53_zone.route53_zone_1.zone_id
  name    = tolist(aws_acm_certificate.acm_1_certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.acm_1_certificate.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.acm_1_certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 60

  depends_on = [aws_acm_certificate.acm_1_certificate]
}

# Validate the ACM certificate using the created Route 53 validation record
resource "aws_acm_certificate_validation" "acm_1_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_1_certificate.arn
  validation_record_fqdns = [aws_route53_record.acm_1_certificate_validation_record.fqdn]

  depends_on = [
    aws_acm_certificate.acm_1_certificate,
    aws_route53_record.acm_1_certificate_validation_record
  ]
}
