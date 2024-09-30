data "aws_ami" "amz-linux" {
 
  most_recent      = true
  owners           = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  amz-linux-ami=data.aws_ami.amz-linux.id
}
output "latest-amz-ami" {
  value = data.aws_ami.amz-linux.id
}
