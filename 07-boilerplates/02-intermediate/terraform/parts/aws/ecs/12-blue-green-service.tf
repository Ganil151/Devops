# 12. ECS Service with Blue/Green (CodeDeploy)
# enabling safe deployment strategies with traffic shifting.

resource "aws_ecs_service" "blue_green" {
  name            = "bg-service"
  cluster         = aws_ecs_cluster.basic.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = var.lb_blue_tg_arn
    container_name   = "web"
    container_port   = 80
  }
}
