# 05. Multi-AZ RDS Instance
# High availability enabled with a standby in a different AZ.

resource "aws_db_instance" "multi_az" {
  allocated_storage      = 50
  engine                 = "mysql"
  instance_class         = "db.t3.medium"
  multi_az               = true
  username               = "admin"
  password               = "Password123!"
  skip_final_snapshot    = true
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_sg_id]

  tags = {
    Name = "Production-HA-Database"
  }
}
