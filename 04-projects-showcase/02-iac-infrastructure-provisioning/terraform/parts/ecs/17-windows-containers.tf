# 17. ECS with Windows Containers
# Running Windows-based workloads on ECS.

resource "aws_ecs_task_definition" "windows_task" {
  family                   = "win-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2019_CORE"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name  = "dotnet-app"
      image = "mcr.microsoft.com/dotnet/framework/aspnet:4.8"
    }
  ])
}
