# 19. ECS with Graviton (ARM) Tasks
# running high-performance ARM-based containers on Fargate.

resource "aws_ecs_task_definition" "arm_task" {
  family                   = "arm-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  runtime_platform {
    cpu_architecture = "ARM64" # Graviton
  }

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "my-arm-image:latest"
    }
  ])
}
