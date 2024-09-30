resource "aws_autoscaling_group" "wp_asg" {
  # no of instances
  desired_capacity  = var.asg_desired_capacity
  max_size          = 2
  min_size          = 1
  target_group_arns = ["${aws_lb_target_group.wp_alb_tg.arn}"]
  # Connect to the target group


  vpc_zone_identifier = [ # Creating EC2 instances in private subnet
    aws_subnet.private[0].id,
    aws_subnet.private[1].id,
  ]

  launch_template {
    id      = aws_launch_template.wp_ec2_launch_templ.id
    version = "$Latest"
  }

}
# Define scaling policies
resource "aws_autoscaling_policy" "scale-up" {
  name                   = "wordpress-cpu-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 500
  autoscaling_group_name = aws_autoscaling_group.wp_asg.name
}

resource "aws_autoscaling_policy" "scale-down" {
  name                   = "wordpress-cpu-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 500
  autoscaling_group_name = aws_autoscaling_group.wp_asg.name
}
