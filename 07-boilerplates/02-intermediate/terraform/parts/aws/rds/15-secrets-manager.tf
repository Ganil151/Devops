# 15. RDS with Secrets Manager Integration
# Automatically rotate database credentials.

resource "aws_db_instance" "secrets_manager" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = var.initial_password
  skip_final_snapshot    = true
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "prod/database/mysql-credentials"
}

resource "aws_secretsmanager_secret_version" "creds" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = aws_db_instance.secrets_manager.username
    password = aws_db_instance.secrets_manager.password
    engine   = "mysql"
    host     = aws_db_instance.secrets_manager.address
    port     = aws_db_instance.secrets_manager.port
  })
}
