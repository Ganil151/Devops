# 19. RDS with Point-in-Time Recovery (PITR)
# Configures the retention period for automated backups.

resource "aws_db_instance" "pitr" {
  allocated_storage       = 20
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "Password123!"
  skip_final_snapshot     = true
  
  backup_retention_period = 35 # Maximum retention for PITR
  backup_window           = "03:00-04:00"
}
