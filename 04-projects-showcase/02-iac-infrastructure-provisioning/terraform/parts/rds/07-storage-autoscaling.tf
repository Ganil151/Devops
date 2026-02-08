# 07. RDS with Storage Auto-scaling
# Automatically increases storage as the database grows.

resource "aws_db_instance" "autoscaling" {
  allocated_storage     = 20
  max_allocated_storage = 100 # Enables storage autoscaling
  engine                = "mysql"
  instance_class        = "db.t3.micro"
  username              = "admin"
  password              = "Password123!"
  skip_final_snapshot   = true

  tags = {
    Name = "Auto-Scaling-Storage-RDS"
  }
}
