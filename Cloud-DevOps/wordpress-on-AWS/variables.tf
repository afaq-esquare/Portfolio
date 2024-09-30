#-------------------------------------------------
# AWS General
#-------------------------------------------------

variable "region" {
  description = "AWS region"
  type        = string
}

#-------------------------------------------------
# VPC
#-------------------------------------------------
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "all_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "The availability zones for the VPC subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}


#-------------------------------------------------
# Security Groups
#-------------------------------------------------
variable "alb_security_group" {
  description = "ALB Security Group"
  type        = string
}
variable "asg_security_group" {
  description = "ASG Security Group"
  type        = string
}
variable "rds_security_group" {
  description = "RDS Security Group"
  type        = string
}
variable "http-port" {
  description = "http port for communication over http"
  type        = number
}
variable "https-port" {
  description = "https port for communication over https"
  type        = number
}
variable "ssh-port" {
  description = "ssh port for communication over ssh"
  type        = number
}
variable "db-port" {
  description = "db port for communication with db"
  type        = number
}

#-------------------------------------------------
# RDS
#-------------------------------------------------
variable "rds_engine" {
  description = "The engine for the RDS instance"
  type        = string
}

variable "rds_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "rds_allocated_storage" {
  description = "The allocated storage for the RDS instance"
  type        = number
}

variable "rds_engine_version" {
  description = "The engine version for the RDS instance"
  type        = string
}

variable "rds_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "rds_db_name" {
  description = "The username for the RDS instance"
  type        = string
}

variable "rds_username" {
  description = "The username for the RDS instance"
  type        = string
}



variable "rds_parameter_group_name" {
  description = "The parameter group name for the RDS instance"
  type        = string
}



#-------------------------------------------------
# LB
#-------------------------------------------------
variable "lb_name" {
  description = "The name of the Application Load Balancer"
  type        = string
}

variable "lb_target_group_name_prefix" {
  description = "The prefix for the target group name"
  type        = string
}

variable "lb_backend_protocol" {
  description = "The protocol used for communication between the Load Balancer and targets"
  type        = string
}

variable "lb_backend_port" {
  description = "The port used for communication between the Load Balancer and targets"
  type        = number
}

variable "lb_target_type" {
  description = "The type of target for the target group"
  type        = string
}

variable "lb_target_port" {
  description = "The port on which the targets receive traffic"
  type        = number
}

variable "lb_http_listener_port" {
  description = "The port for the HTTP listener"
  type        = number
}

variable "lb_http_listener_protocol" {
  description = "The protocol for the HTTP listener"
  type        = string
}

variable "lb_https_listener_port" {
  description = "The port for the HTTPS listener"
  type        = number
}

variable "lb_https_listener_protocol" {
  description = "The protocol for the HTTPS listener"
  type        = string
}

#-------------------------------------------------
# ASG
#-------------------------------------------------
variable "asg_name" {
  description = "The name of the Autoscaling Group"
  type        = string
}

variable "asg_instance_name" {
  description = "The name of the Autoscaling Instance"
  type        = string
}

variable "asg_min_size" {
  description = "The minimum number of instances in the Autoscaling Group"
  type        = number
}

variable "asg_max_size" {
  description = "The maximum number of instances in the Autoscaling Group"
  type        = number
}

variable "asg_desired_capacity" {
  description = "The desired capacity of the Autoscaling Group"
  type        = number
}

variable "asg_health_check_type" {
  description = "The health check type for the Autoscaling Group"
  type        = string
}

variable "asg_wait_for_capacity_timeout" {
  description = "The timeout value for waiting for capacity in the Autoscaling Group"
  type        = number
}


variable "asg_launch_template_name" {
  description = "The name of the Launch Template for the Autoscaling Group"
  type        = string
}

variable "asg_launch_template_description" {
  description = "The description of the Launch Template for the Autoscaling Group"
  type        = string
}

variable "asg_update_default_version" {
  description = "Whether to update the default version of the Launch Template"
  type        = bool
}



variable "asg_instance_type" {
  description = "The type of instances in the Autoscaling Group"
  type        = string
}

variable "key_name" {
  description = "The key pair name for the EC2 instance"
  type        = string
}

#-------------------------------------------------
# DB SUbnet Group
#-------------------------------------------------
variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}

variable "db_subnet_group_description" {
  description = "The description of the DB subnet group"
  type        = string
}

#-------------------------------------------------
# ROute 53
#-------------------------------------------------
variable "domain_name" {
  description = "The name of the domain/sub domian"
  type        = string
}

variable "zone_name" {
  description = "The name of the domain/sub domian"
  type        = string
}
#-------------------------------------------------
# tags
#-------------------------------------------------
variable "tags" {
  type = map(string)
}
