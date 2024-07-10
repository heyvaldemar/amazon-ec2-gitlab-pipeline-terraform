# Private subnet creation
resource "aws_subnet" "private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.private_subnet_1a_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-gitlab-1-${var.region}a"
  }

  depends_on = [aws_vpc.vpc_1]
}

# Private subnet creation
resource "aws_subnet" "private_subnet_1b" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.private_subnet_1b_cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-gitlab-1-${var.region}b"
  }

  depends_on = [aws_vpc.vpc_1]
}

# Private subnet creation
resource "aws_subnet" "private_subnet_1c" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.private_subnet_1c_cidr
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-gitlab-1-${var.region}c"
  }

  depends_on = [aws_vpc.vpc_1]
}

# Public subnet creation
resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = var.public_subnet_1a_cidr
  availability_zone = "${var.region}a"
  #tfsec:ignore:aws-ec2-no-public-ip-subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "public-gitlab-1-${var.region}a"
  }

  depends_on = [aws_vpc.vpc_1]
}

# Public subnet creation
resource "aws_subnet" "public_subnet_1b" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = var.public_subnet_1b_cidr
  availability_zone = "${var.region}b"
  #tfsec:ignore:aws-ec2-no-public-ip-subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "public-gitlab-1-${var.region}b"
  }

  depends_on = [aws_vpc.vpc_1]
}
