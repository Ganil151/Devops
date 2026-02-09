# 20. Minimalist ECS Cluster
# The absolute barebones code for an ECS cluster.

resource "aws_ecs_cluster" "minimal" {
  name = "baseline-cluster"
}
