# 04. Aurora PostgreSQL Cluster
# Managed PostgreSQL cluster for enterprise applications.

resource "aws_rds_cluster" "aurora_postgres" {
  cluster_identifier      = "aurora-cluster-postgres"
  engine                  = "aurora-postgresql"
  engine_version          = "14.6"
  database_name           = "auroradb_pg"
  master_username         = "admin"
  master_password         = "Password123!"
  skip_final_snapshot     = true
  storage_encrypted       = true
}

resource "aws_rds_cluster_instance" "pg_instances" {
  count              = 2
  identifier         = "aurora-pg-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_postgres.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.aurora_postgres.engine
  engine_version     = aws_rds_cluster.aurora_postgres.engine_version
}
