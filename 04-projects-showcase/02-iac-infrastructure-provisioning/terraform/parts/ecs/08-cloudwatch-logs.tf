# 08. ECS with CloudWatch Logs Integration
# routing container stdout/stderr to CloudWatch for centralized logging.

resource "aws_ecs_task_definition" "logged_task" {
  family                   = "logged-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "nginx"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/logged-app"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}
