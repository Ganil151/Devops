# 16. Aurora Serverless V2
# Scales capacity up and down based on application demand.

resource "aws_rds_cluster" "serverless_v2" {
  cluster_identifier = "aurora-serverless-v2"
  engine             = "aurora-mysql"
  engine_mode        = "provisioned" # V2 uses provisioned mode with serverless instances
  engine_version     = "8.0.mysql_aurora.3.02.0"
  master_username    = "admin"
  master_password    = "Password123!"
  skip_final_snapshot = true

  serverless_v2_scaling_configuration {
    max_capacity = 16.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "serverless_instance" {
  count              = 2
  identifier         = "serverless-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.serverless_v2.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.serverless_v2.engine
  engine_version     = aws_rds_cluster.serverless_v2.engine_version
}
