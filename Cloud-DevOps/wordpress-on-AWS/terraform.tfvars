#-------------------------------------------------
# AWS Gneral
#-------------------------------------------------
region = "us-east-1"

#-------------------------------------------------
# VPC
#-------------------------------------------------
vpc_name        = "wordpress-vpc"
vpc_cidr        = "10.100.0.0/16"
all_cidr        = "0.0.0.0/0"
azs             = ["us-east-2a", "us-east-2b"]
private_subnets = ["10.100.3.0/24", "10.100.4.0/24"]
public_subnets  = ["10.100.1.0/24", "10.100.2.0/24"]



#-------------------------------------------------
# Security Groups
#-------------------------------------------------
asg_security_group = "allow_ssh"
alb_security_group = "sg_for_elb_wp_test"
rds_security_group = "database-sg"
http-port= 80
https-port=443
db-port = 3306
ssh-port = 22
#-------------------------------------------------
# RDS
#-------------------------------------------------
rds_engine               = "mysql"
rds_engine_version       = "5.7.44"
rds_instance_class       = "db.t3.micro"
rds_allocated_storage    = 10
rds_identifier           = "wordpress-rds-instance"
rds_db_name              = "wordpress_db"
rds_username             = "mani"
rds_parameter_group_name = "default.mysql5.7"


#-------------------------------------------------
# LB
#-------------------------------------------------
lb_name                     = "wordpress-lb-asg"
lb_target_group_name_prefix = "wp-lb-alb-tg"
lb_backend_protocol         = "HTTP"
lb_backend_port             = 80
lb_target_type              = "instance"
lb_target_port              = 80
lb_http_listener_port       = 80
lb_http_listener_protocol   = "HTTP"
lb_https_listener_port      = 443
lb_https_listener_protocol  = "HTTPS"


#-------------------------------------------------
# ASG
#-------------------------------------------------
asg_name                        = "wordpress-asg"
asg_instance_name               = "wordpress_instance"
asg_min_size                    = 1
asg_max_size                    = 2
asg_desired_capacity            = 1
asg_health_check_type           = "ELB"
asg_wait_for_capacity_timeout   = 500
asg_launch_template_name        = "wp_ec2_launch_templ"
asg_launch_template_description = "Wordpress Launch Template"
asg_update_default_version      = true
asg_instance_type               = "t2.micro"
key_name                        = "wp-key"


#-------------------------------------------------
# DB Subnet Group
#-------------------------------------------------
db_subnet_group_name        = "rds-subnet-group"
db_subnet_group_description = "rds-subnet-group"


#-------------------------------------------------
# Route53 
#-------------------------------------------------
domain_name = "wp-abdullah.equationsquare.com"
zone_name   = "equationsquare.com"



#-------------------------------------------------
# tags 
#-------------------------------------------------
tags = {
  owner   = "abdullah.tarar@equationsqaure"
  creator = "abdullah.tarar@equationsquare"
}
