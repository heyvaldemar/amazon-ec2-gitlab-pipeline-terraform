# Internet gateway creation
resource "aws_internet_gateway" "igw_1" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "igw-gitlab-1"
  }

  depends_on = [aws_vpc.vpc_1]
}
