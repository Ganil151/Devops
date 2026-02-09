# 10. Lambda with Container Image (ECR)
# packaging the function as a Docker image for larger deployments.

resource "aws_lambda_function" "container_lambda" {
  function_name = "containerized-app"
  role          = var.lambda_role_arn
  package_type  = "Image"
  image_uri     = "${var.ecr_repository_url}:latest"

  timeout     = 30
  memory_size = 512
}
