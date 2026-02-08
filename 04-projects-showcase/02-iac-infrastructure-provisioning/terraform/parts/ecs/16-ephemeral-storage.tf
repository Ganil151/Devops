# 16. ECS Task with Ephemeral Storage
# increasing the disk space available to Farate tasks (up to 200GB).

resource "aws_ecs_task_definition" "big_disk" {
  family                   = "data-processor-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096

  ephemeral_storage {
    size_in_gib = 100 # Default is 20GB
  }

  container_definitions = jsonencode([
    {
      name  = "processor"
      image = "my-batch-job:latest"
    }
  ])
}
