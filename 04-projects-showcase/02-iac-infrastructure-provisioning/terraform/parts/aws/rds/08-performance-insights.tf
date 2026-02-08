# 08. RDS with Performance Insights
# Enables monitoring of database load and performance diagnosis.

resource "aws_db_instance" "performance_insights" {
  allocated_storage            = 20
  engine                       = "mysql"
  instance_class               = "db.t3.micro"
  username                     = "admin"
  password                     = "Password123!"
  skip_final_snapshot          = true
  
  performance_insights_enabled = true
  performance_insights_retention_period = 7 # Days
}
