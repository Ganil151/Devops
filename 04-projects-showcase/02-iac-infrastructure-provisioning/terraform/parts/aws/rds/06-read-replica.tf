# 06. RDS Read Replica
# Offload read traffic to a secondary instance.

resource "aws_db_instance" "master" {
  allocated_storage   = 20
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "Password123!"
  backup_retention_period = 7 # Required for read replicas
  skip_final_snapshot = true
}

resource "aws_db_instance" "replica" {
  replicate_source_db = aws_db_instance.master.identifier
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  
  tags = {
    Name = "MySQL-Read-Replica"
  }
}
