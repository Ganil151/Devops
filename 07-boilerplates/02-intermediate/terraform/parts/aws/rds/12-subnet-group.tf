# 12. RDS in a Custom Subnet Group
# Ensures the database is placed in specific private subnets.

resource "aws_db_subnet_group" "private_db_subnets" {
  name       = "main-db-subnet-group"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]

  tags = {
    Name = "Private-DB-Subnet-Group"
  }
}

resource "aws_db_instance" "subnetted" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "Password123!"
  db_subnet_group_name   = aws_db_subnet_group.private_db_subnets.name
  skip_final_snapshot    = true
}
