
#rds subnet
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]
}


# RDS Instance
resource "aws_db_instance" "rds_instance" {
  engine                    = var.rds_engine
  engine_version            = var.rds_engine_version
  skip_final_snapshot       = true
  final_snapshot_identifier = "my-final-snapshot"
  instance_class            = var.rds_instance_class
  allocated_storage         = var.rds_allocated_storage
  multi_az                  = true
  identifier                = var.rds_identifier
  db_name                   = var.rds_db_name
  username                  = var.rds_username
  manage_master_user_password = true
  db_subnet_group_name      = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.database-sg.id]
  tags = {
    Name = "WP_RDS"
  }
 
}



