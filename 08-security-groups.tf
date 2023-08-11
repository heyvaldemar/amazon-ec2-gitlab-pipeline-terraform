# Security group creation
resource "aws_security_group" "rds_security_group_1" {
  vpc_id = aws_vpc.vpc_1.id

  name        = "rds-security-group-gitlab-1"
  description = "RDS Security Group GitLab 1"

  # Inbound port configuration
  ingress {
    description     = "Allow inbound traffic on port 5432 for PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_security_group_1.id]
  }

  # Outbound port configuration
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:aws-vpc-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.vpc_1]
}

# Security group creation
resource "aws_security_group" "redis_security_group_1" {
  vpc_id = aws_vpc.vpc_1.id

  name        = "redis-security-group-gitlab-1"
  description = "Redis Security Group GitLab 1"

  # Inbound port configuration
  ingress {
    description = "Allow inbound traffic on port 6379 for Redis from specific CIDR blocks"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"

    cidr_blocks = [
      var.private_subnet_1a_cidr,
      var.private_subnet_1b_cidr,
      var.private_subnet_1c_cidr
    ]
  }

  # Outbound port configuration
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group creation
resource "aws_security_group" "ec2_security_group_1" {
  vpc_id = aws_vpc.vpc_1.id

  name        = "instance-security-group-gitlab-1"
  description = "Instance Security Group GitLab 1"

  # Inbound port configuration for ALB on port 80
  ingress {
    description     = "Allow inbound HTTP traffic from ALB security group"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_1_security_group_1.id]
  }

  # Inbound port configuration for ALB on port 443
  ingress {
    description     = "Allow inbound HTTPS traffic from ALB security group"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_1_security_group_1.id]
  }

  # Inbound port configuration
  ingress {
    description = "Allow inbound SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound port configuration for Redis
  ingress {
    description     = "Allow inbound traffic on port 6379 for Redis from Redis security group"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.redis_security_group_1.id]
  }

  # Outbound port configuration
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.vpc_1]
}

resource "aws_security_group" "alb_1_security_group_1" {
  vpc_id = aws_vpc.vpc_1.id

  name        = "application-load-balancer-1-gitlab-1"
  description = "Allow inbound traffic for the load balancer"

  # Inbound port configuration
  ingress {
    description = "Allow inbound HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound port configuration
  ingress {
    description = "Allow inbound HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound port configuration
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }
}
