resource "aws_lb" "wordpress_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_for_elb_wp.id]
  subnets            = [aws_subnet.public[0].id, aws_subnet.public[1].id]
  
}

# Target Group
resource "aws_lb_target_group" "wp_alb_tg" {
  name     = var.lb_target_group_name_prefix
  port     = var.lb_target_port
  protocol = var.lb_backend_protocol
  vpc_id   = aws_vpc.wordpress-vpc.id
}


# HTTP Listener
resource "aws_lb_listener" "wp_front_end" {
  load_balancer_arn = aws_lb.wordpress_lb.arn
  port              = var.lb_http_listener_port
  protocol          = var.lb_http_listener_protocol

  default_action {
    type = "redirect"
    redirect {
      port        = var.lb_https_listener_port
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_lb.wordpress_lb.arn
  port              = var.lb_https_listener_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.acm_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp_alb_tg.arn
  }
}
