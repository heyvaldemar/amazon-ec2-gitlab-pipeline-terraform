# Elastic IP allocation
resource "aws_eip" "nat_eip_1" {
  domain = "vpc"

  tags = {
    Name = "nat-eip-gitlab-1"
  }

  depends_on = [aws_vpc.vpc_1]
}

# Public NAT creation
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name = "nat-gitlab-1"
  }

  depends_on = [
    aws_internet_gateway.igw_1,
    aws_eip.nat_eip_1,
    aws_subnet.public_subnet_1a
  ]
}
