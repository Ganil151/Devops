# 06. Database Subnet
# Usually isolated or private, with specific tagging for RDS subnet groups.

resource "aws_subnet" "database" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Database-Subnet"
    Tier = "Data"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.database.id]

  tags = {
    Name = "Main DB Subnet Group"
  }
}
