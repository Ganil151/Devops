# 10. RDS with Custom Parameter Group
# Fine-tune database engine settings.

resource "aws_db_parameter_group" "custom_mysql" {
  name   = "custom-mysql-params"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "max_connections"
    value = "1000"
  }
}

resource "aws_db_instance" "parameterized" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "Password123!"
  parameter_group_name = aws_db_parameter_group.custom_mysql.name
  skip_final_snapshot  = true
}
