# 15. ECS with App Mesh Integration
# managing microservices traffic and observability using a service mesh.

resource "aws_ecs_task_definition" "mesh_task" {
  family                   = "meshed-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "my-app:v1"
    },
    {
      name  = "envoy"
      image = "840242741065.dkr.ecr.us-east-1.amazonaws.com/aws-appmesh-envoy:v1.22.2.1-prod"
      # Proxy configuration for App Mesh
    }
  ])
}
# (Note: Requires App Mesh Virtual Node and Service configured)
