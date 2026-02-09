# 14. ECS with Service Connect
# enabling microservices to communicate with each other using logical names.

resource "aws_ecs_service" "service_connect" {
  name            = "api-service"
  cluster         = aws_ecs_cluster.basic.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  desired_count   = 2

  service_connect_configuration {
    enabled   = true
    namespace = var.cloud_map_namespace_arn
    service {
      port_name      = "http-port"
      discovery_name = "api"
      client_alias {
        port     = 80
        dns_name = "api.local"
      }
    }
  }
}
