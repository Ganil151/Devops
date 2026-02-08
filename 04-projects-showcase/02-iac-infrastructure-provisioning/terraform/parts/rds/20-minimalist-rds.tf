# 20. Minimalist RDS Instance
# Barebones configuration for rapid testing.

resource "aws_db_instance" "minimal" {
  allocated_storage   = 10
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  username            = "user"
  password            = "pass"
  skip_final_snapshot = true
}
