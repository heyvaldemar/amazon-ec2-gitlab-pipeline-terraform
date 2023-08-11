# Retrieves Route 53 hosted zone details using the provided zone name
data "aws_route53_zone" "route53_zone_1" {
  name = var.route53_zone_1_name
}

# Creates an A record in the Route 53 hosted zone
resource "aws_route53_record" "gitlab_heyvalemar_net" {
  zone_id = data.aws_route53_zone.route53_zone_1.zone_id
  name    = "gitlab.${data.aws_route53_zone.route53_zone_1.name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb_1.dns_name
    zone_id                = aws_lb.alb_1.zone_id
    evaluate_target_health = false
  }

  depends_on = [aws_lb.alb_1]
}

# Creates an A record in the Route 53 hosted zone
resource "aws_route53_record" "ssh_heyvaldemar_net" {
  zone_id = data.aws_route53_zone.route53_zone_1.zone_id
  name    = "ssh.${data.aws_route53_zone.route53_zone_1.name}"
  type    = "A"

  alias {
    name                   = aws_lb.nlb_1.dns_name
    zone_id                = aws_lb.nlb_1.zone_id
    evaluate_target_health = false
  }

  depends_on = [aws_lb.nlb_1]
}
