# 09. ECS with EFS Volume (Persistent Storage)
# mounting an Elastic File System to a container for persistent data.

resource "aws_ecs_task_definition" "efs_task" {
  family                   = "database-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name  = "db"
      image = "mysql"
      mountPoints = [
        {
          containerPath = "/var/lib/mysql"
          sourceVolume  = "my-efs-volume"
        }
      ]
    }
  ])

  volume {
    name = "my-efs-volume"
    efs_volume_configuration {
      file_system_id = var.efs_id
      root_directory = "/"
    }
  }
}
