resource "aws_db_instance" "tf_rds_instance" {
  allocated_storage      = 10
  db_name                = "users"
  identifier             = "nodejs-rds-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "Ganil3773"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.tf_rds_sg.id]
}

resource "aws_security_group" "tf_rds_sg" {
  vpc_id      = "vpc-04291380fa4d7c296"
  name        = "allow_mysql"
  description = "Allow MySQL traffic"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["148.101.252.23/32"]
    security_groups = [ aws_security_group.ec2_youtube_sg.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Add local variable for endpoint
locals {
  rds_endpoint = element(split(":", aws_db_instance.tf_rds_instance.endpoint), 0)
}

# Output the endpoint
output "rds_endpoint" {
  value = local.rds_endpoint
}
# Output the username
output "rds_username" {
  value = aws_db_instance.tf_rds_instance.username
}
# Output the database-name
output "db_name" {
  value = aws_db_instance.tf_rds_instance.db_name
}


# https://youtu.be/bEXfPzoB4RE