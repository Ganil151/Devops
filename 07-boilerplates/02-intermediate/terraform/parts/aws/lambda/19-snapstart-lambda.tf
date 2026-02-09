# 19. Lambda with SnapStart
# reducing startup time (cold start) for Java-based functions.

resource "aws_lambda_function" "java_snapstart" {
  filename      = "app.jar"
  function_name = "fast-java-startup"
  role          = var.lambda_role_arn
  handler       = "com.example.Handler"
  runtime       = "java11"

  snap_start {
    apply_on = "PublishedVersions"
  }
}
# (Note: Requires publishing a version to take effect)
