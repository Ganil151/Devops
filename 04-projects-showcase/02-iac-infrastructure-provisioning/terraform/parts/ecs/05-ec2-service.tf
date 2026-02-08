# 05. ECS EC2 Service
# Running tasks on a fleet of managed EC2 instances.

resource "aws_ecs_service" "ec2_service" {
  name            = "ec2-backend-service"
  cluster         = aws_ecs_cluster.basic.id
  task_definition = aws_ecs_task_definition.ec2_task.arn
  desired_count   = 3
  launch_type     = "EC2"

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }
}
