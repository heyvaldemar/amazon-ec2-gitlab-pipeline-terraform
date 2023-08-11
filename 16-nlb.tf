# NLB creation
resource "aws_lb" "nlb_1" {
  name = "nlb-gitlab-1"
  #tfsec:ignore:aws-elb-alb-not-public
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnet_1a.id]

  enable_deletion_protection = true
  depends_on                 = [aws_subnet.public_subnet_1a]
}

# Target Group for port 22
resource "aws_lb_target_group" "nlb_1_target_group_22" {
  name        = "target-group-22-gitlab-1"
  port        = 22
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc_1.id
  target_type = "instance"

  health_check {
    interval = 30
    port     = "traffic-port"
    timeout  = 10
    protocol = "TCP"
  }
}

# Listener for port 22
resource "aws_lb_listener" "nlb_1_listener_22" {
  load_balancer_arn = aws_lb.nlb_1.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_1_target_group_22.arn
  }
}

# Target Group attachment for port 22
resource "aws_lb_target_group_attachment" "nlb_1_target_group_22_attachment" {
  target_group_arn = aws_lb_target_group.nlb_1_target_group_22.arn
  target_id        = aws_instance.instance_1.id
  port             = 22
}
