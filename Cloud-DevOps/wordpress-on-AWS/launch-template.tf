
# ASG with Launch template

resource "aws_key_pair" "wp-key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa-tr-key.public_key_openssh
}

resource "tls_private_key" "rsa-tr-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "rsa-tr-key" {
  content  = tls_private_key.rsa-tr-key.private_key_pem
  filename = "${path.module}/rsa-tr-key"
}

//Launch Template
resource "aws_launch_template" "wp_ec2_launch_templ" {
  name_prefix   = var.asg_launch_template_name
  image_id      = data.aws_ami.amz-linux.id # To note: AMI is specific for each region
  instance_type = var.asg_instance_type
  key_name      = aws_key_pair.wp-key.key_name

  user_data = base64encode(templatefile("${path.module}/amazon.sh", {
    DB_NAME     = aws_db_instance.rds_instance.db_name
    DB_USER     = aws_db_instance.rds_instance.username
    DB_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.rds_master.secret_string).password
    DB_HOST     = aws_db_instance.rds_instance.endpoint
  }))



  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.private[0].id
    security_groups             = [aws_security_group.wordpress-ec2-instance-sg.id]
  }


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wordpress-instance-test" # Name for the EC2 instances
    }
  }
}