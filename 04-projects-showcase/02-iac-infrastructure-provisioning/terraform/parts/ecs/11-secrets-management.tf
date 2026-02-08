# 11. ECS with Secrets Manager Integration
# injecting sensitive information (API keys, DB passwords) into the container securely.

resource "aws_ecs_task_definition" "secret_task" {
  family                   = "secret-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_exec_role_arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "my-app:latest"
      secrets = [
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = var.secret_arn
        }
      ]
    }
  ])
}
