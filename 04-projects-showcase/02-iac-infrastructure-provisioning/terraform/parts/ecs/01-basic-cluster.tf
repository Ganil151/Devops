# 01. Basic ECS Cluster
# The logical grouping of tasks or services.

resource "aws_ecs_cluster" "basic" {
  name = "app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
