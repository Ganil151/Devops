# 01. Basic MySQL RDS Instance
# Standard single-AZ deployment for development.

resource "aws_db_instance" "mysql_basic" {
  allocated_storage    = 20
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "Password123!" # In production, use Secrets Manager
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  
  tags = {
    Name = "Basic-MySQL-Instance"
  }
}
