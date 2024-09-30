output "database_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.rds_instance.endpoint
}

output "lb_endpoint" {
  description = "Load balancer endpoint for the Wordpress Server"
  value       = "http://${aws_lb.wordpress_lb.dns_name}"
}

output "public-domain" {
  description = "route 53 record pointing to ALB"
  value       = "https://${var.domain_name}"
}