# 18. ECS with Exec Enabled
# allowing interactive access (shell) into running containers for debugging.

resource "aws_ecs_service" "debug_service" {
  name                   = "debug-service"
  cluster                = aws_ecs_cluster.basic.id
  task_definition        = aws_ecs_task_definition.fargate_task.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true # Required for 'ecs exec'

  network_configuration {
    subnets = var.private_subnet_ids
  }
}
# (Note: IAM roles must also have permissions for SSM Messages)
