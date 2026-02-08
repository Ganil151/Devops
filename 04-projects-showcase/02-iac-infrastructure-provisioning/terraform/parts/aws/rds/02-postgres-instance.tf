# 02. PostgreSQL RDS Instance
# Standard PostgreSQL deployment.

resource "aws_db_instance" "postgres_basic" {
  allocated_storage      = 20
  db_name                = "postgresdb"
  engine                 = "postgres"
  engine_version         = "15.0"
  instance_class         = "db.t3.micro"
  username               = "postgres"
  password               = "Password123!"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = var.db_subnet_group_name

  tags = {
    Name = "Basic-Postgres-Instance"
  }
}
