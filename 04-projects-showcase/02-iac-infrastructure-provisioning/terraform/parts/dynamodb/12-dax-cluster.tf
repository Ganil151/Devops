# 12. DynamoDB Accelerator (DAX) Cluster
# In-memory cache for DynamoDB to provide microsecond response times.

resource "aws_dax_cluster" "main" {
  cluster_name       = "app-dax-cluster"
  iam_role_arn       = var.dax_role_arn
  node_type          = "dax.t3.medium"
  replication_factor = 3
  subnet_group_name  = var.dax_subnet_group_name
  security_group_ids = [var.dax_sg_id]
}
