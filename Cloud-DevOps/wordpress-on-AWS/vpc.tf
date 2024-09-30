# Create VPC
resource "aws_vpc" "wordpress-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# Create public and private subnets
locals {
  subnet_count = length(var.public_subnets)
}

resource "aws_subnet" "public" {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.wordpress-vpc.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]

  tags = {
    Name = "wordpress-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.wordpress-vpc.id
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[count.index]

  tags = {
    Name = "wordpress-private-${count.index + 1}"
  }
}
