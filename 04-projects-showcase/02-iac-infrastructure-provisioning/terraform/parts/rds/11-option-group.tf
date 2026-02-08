# 11. RDS with Custom Option Group
# Add additional features (e.g., Transparent Data Encryption).

resource "aws_db_option_group" "mysql_options" {
  name                     = "custom-mysql-options"
  engine_name              = "mysql"
  major_engine_version     = "8.0"

  option {
    option_name = "MEMCACHED"
  }
}

resource "aws_db_instance" "optioned" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "Password123!"
  option_group_name    = aws_db_option_group.mysql_options.name
  skip_final_snapshot  = true
}
