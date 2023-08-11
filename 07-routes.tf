# Private route table creation
resource "aws_route_table" "private_route_1" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block     = var.private_route_1_cidr
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

  tags = {
    Name = "private-route-gitlab-1"
  }

  depends_on = [aws_nat_gateway.nat_1]
}

# Public route table creation
resource "aws_route_table" "public_route_1" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = var.public_route_1_cidr
    gateway_id = aws_internet_gateway.igw_1.id
  }

  tags = {
    Name = "public-route-gitlab-1"
  }

  depends_on = [aws_internet_gateway.igw_1]
}

# Private route table association
resource "aws_route_table_association" "private_subnet_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_route_1.id

  depends_on = [
    aws_subnet.private_subnet_1a,
    aws_route_table.private_route_1
  ]
}

# Private route table association
resource "aws_route_table_association" "private_subnet_1b" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.private_route_1.id

  depends_on = [
    aws_subnet.private_subnet_1b,
    aws_route_table.private_route_1
  ]
}

# Private route table association
resource "aws_route_table_association" "private_subnet_1c" {
  subnet_id      = aws_subnet.private_subnet_1c.id
  route_table_id = aws_route_table.private_route_1.id

  depends_on = [
    aws_subnet.private_subnet_1c,
    aws_route_table.private_route_1
  ]
}

# Public route table association
resource "aws_route_table_association" "public_subnet_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_route_1.id

  depends_on = [
    aws_subnet.public_subnet_1a,
    aws_route_table.public_route_1
  ]
}

# Public route table association
resource "aws_route_table_association" "public_subnet_1b" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public_route_1.id

  depends_on = [
    aws_subnet.public_subnet_1b,
    aws_route_table.public_route_1
  ]
}
