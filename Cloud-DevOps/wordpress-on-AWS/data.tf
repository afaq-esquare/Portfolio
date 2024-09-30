
###Route 53 zone 
data "aws_route53_zone" "selected" {
  name         = "xldp.xgrid.co"
}

data "aws_secretsmanager_secret_version" "rds_master" {
  secret_id = aws_db_instance.rds_instance.master_user_secret[0].secret_arn
}
       
