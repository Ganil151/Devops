resource "aws_secretsmanager_secret" "db_creds" {
  name = "${var.environment}/petclinic/db"
}

# The version/value is usually created outside of TF or with a dummy value initially
resource "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode({
    username = "admin"
    password = var.password
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
