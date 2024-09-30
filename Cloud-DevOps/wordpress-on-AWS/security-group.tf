#security group
resource "aws_security_group" "wordpress-ec2-instance-sg" {
  name        = var.asg_security_group
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.wordpress-vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = var.ssh-port
    to_port     = var.ssh-port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description     = "Allow HTTP"
    protocol        = "tcp"
    from_port       = var.http-port
    to_port         = var.http-port
    cidr_blocks     = [var.vpc_cidr]
    security_groups = [aws_security_group.sg_for_elb_wp.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "wordpress_ssh,HTTP"
  }
}

resource "aws_security_group" "database-sg" {
  name        = var.rds_security_group
  description = "security  group for database to allow traffic on port 3306 and from ec2 production security group"
  vpc_id      = aws_vpc.wordpress-vpc.id

  ingress {
    description     = "Allow traffic from port 3306 and from ec2 production security group"
    from_port       = var.db-port
    to_port         = var.db-port
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress-ec2-instance-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "wordpress-database-sg"
  }
}


resource "aws_security_group" "sg_for_elb_wp" {
  name   = var.alb_security_group
  vpc_id = aws_vpc.wordpress-vpc.id

  ingress {
    description      = "Allow http request from anywhere"
    protocol         = "tcp"
    from_port        = var.http-port
    to_port          = var.http-port
    cidr_blocks      = [var.all_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow https request from anywhere"
    protocol         = "tcp"
    from_port        = var.https-port
    to_port          = var.https-port
    cidr_blocks      = [var.all_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "wordpress-load-balancer-sg"
  }
}
