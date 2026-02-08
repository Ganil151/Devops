# 03. Aurora MySQL Cluster
# High-performance distributed database cluster.

resource "aws_rds_cluster" "aurora_mysql" {
  cluster_identifier      = "aurora-cluster-mysql"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.02.0"
  database_name           = "auroradb"
  master_username         = "admin"
  master_password         = "Password123!"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "aurora-mysql-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_mysql.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora_mysql.engine
  engine_version     = aws_rds_cluster.aurora_mysql.engine_version
}
