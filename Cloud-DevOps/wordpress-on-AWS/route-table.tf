# It enables our vpc to connect to the internet
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.wordpress-vpc.id

  tags = {
    Name = "wordpress_internet_gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.wordpress-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
 
  
  tags = {
    Name = "public-route-table-wp"
  }
}

resource "aws_eip" "elastic_ip" {
  tags = {
    Name = "wordpress_eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id     = aws_eip.elastic_ip.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[0].id

  tags = {
    Name = "wordpress_nat"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.wordpress-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  
  tags = {
    Name = "private-route-table-wp"


  }
}

resource "aws_route_table_association" "public_rt_assoc1" {
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_rt_assoc2" {
  subnet_id      = aws_subnet.public[1].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_rt_assoc1" {
  subnet_id      = aws_subnet.private[0].id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "private_rt_assoc2" {
  subnet_id      = aws_subnet.private[1].id
  route_table_id = aws_route_table.private_route_table.id
}