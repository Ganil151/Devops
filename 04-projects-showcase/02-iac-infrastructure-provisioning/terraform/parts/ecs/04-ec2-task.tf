# 04. ECS Task Definition (EC2)
# Task definition specifically for EC2 launch type (host networking/bridge).

resource "aws_ecs_task_definition" "ec2_task" {
  family                   = "legacy-app-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "my-repo/app:v1"
      essential = true
      memory    = 512
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 0 # Dynamic port mapping
        }
      ]
    }
  ])
}
