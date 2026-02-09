# 13. ECS Cluster with VPC Flow Logs
# monitoring network traffic for the ECS cluster.

# (Note: This is usually configured at the VPC level, but tagging helps)

resource "aws_ecs_cluster" "monitored" {
  name = "monitored-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
