# 03. Database Security Group
# Allows traffic only from the application security group.

resource "aws_security_group" "db_sg" {
  name        = "database-sg"
  description = "Allows DB access only from the App Tier"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Database-SG"
  }
}

resource "aws_security_group_rule" "allow_postgres" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.db_sg.id
  description              = "Allow Postgres from App SG"
}
