# 14. RDS with IAM Authentication
# Connect to the database using IAM roles instead of passwords.

resource "aws_db_instance" "iam_auth" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "Password123!"
  skip_final_snapshot    = true
  
  iam_database_authentication_enabled = true
}
