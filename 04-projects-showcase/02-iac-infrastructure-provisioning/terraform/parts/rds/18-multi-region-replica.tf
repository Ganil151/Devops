# 18. Multi-Region Read Replica
# Replicate the database to a secondary AWS region for disaster recovery.

resource "aws_db_instance" "primary_region" {
  allocated_storage       = 20
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "Password123!"
  backup_retention_period = 7
  skip_final_snapshot     = true
}

# The replica would be created in a secondary provider block
# provider "aws" { alias = "secondary" region = "us-west-2" }

resource "aws_db_instance" "secondary_region_replica" {
  # provider            = aws.secondary
  replicate_source_db = aws_db_instance.primary_region.arn # Use ARN for cross-region
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
}
