# 10. ECS Scheduled Task (Cron)
# Running a containerized job on a recurring schedule using EventBridge.

resource "aws_cloudwatch_event_rule" "nightly_job" {
  name                = "nightly-cleanup-task"
  schedule_expression = "cron(0 2 * * ? *)"
}

resource "aws_cloudwatch_event_target" "ecs_cron" {
  rule      = aws_cloudwatch_event_rule.nightly_job.name
  target_id = "CleanupJob"
  arn       = aws_ecs_cluster.basic.arn
  role_arn  = var.event_role_arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.fargate_task.arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets = var.private_subnet_ids
    }
  }
}
