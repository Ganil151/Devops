# 03. ECS Fargate Service
# managing the desired number of tasks and integration with LB.

resource "aws_ecs_service" "fargate_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.basic.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "web"
    container_port   = 80
  }
}
