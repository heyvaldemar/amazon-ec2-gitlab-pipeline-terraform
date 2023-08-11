# ALB creation
resource "aws_lb" "alb_1" {
  name = "alb-gitlab-ps-1"
  #tfsec:ignore:aws-elb-alb-not-public
  internal                   = false
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  security_groups            = [aws_security_group.alb_1_security_group_1.id]

  enable_deletion_protection = true
  subnets = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1b.id
  ]

  depends_on = [
    aws_security_group.alb_1_security_group_1,
    aws_subnet.public_subnet_1a,
    aws_subnet.public_subnet_1b
  ]
}

# Target Group creation
resource "aws_lb_target_group" "alb_1_target_group_1" {
  name     = "target-group-80-gitlab-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_1.id

  health_check {
    path                = "/users/sign_in"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  depends_on = [
    aws_vpc.vpc_1,
    aws_lb.alb_1
  ]
}

# Listener creation
resource "aws_lb_listener" "alb_1_http_listener_1" {
  load_balancer_arn = aws_lb.alb_1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [aws_lb.alb_1]
}

# Listener creation
resource "aws_lb_listener" "alb_1_https_listener_1" {
  load_balancer_arn = aws_lb.alb_1.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate_validation.acm_1_certificate_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_1_target_group_1.arn
  }

  depends_on = [
    aws_lb.alb_1,
    aws_lb_target_group.alb_1_target_group_1,
    aws_acm_certificate_validation.acm_1_certificate_validation
  ]
}

# Target Group attachment
resource "aws_lb_target_group_attachment" "alb_1_target_group_1_attachment" {
  target_group_arn = aws_lb_target_group.alb_1_target_group_1.arn
  target_id        = aws_instance.instance_1.id
  port             = 80

  depends_on = [
    aws_lb.alb_1,
    aws_instance.instance_1,
    aws_lb_target_group.alb_1_target_group_1
  ]
}
