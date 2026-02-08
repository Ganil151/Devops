# 06. CloudWatch Synthetics Canary
# running heartbeat scripts to monitor web application availability and latency.

resource "aws_synthetics_canary" "web_check" {
  name                 = "web-heartbeat"
  artifact_s3_location = "s3://${var.bucket_name}/canary/"
  execution_role_arn   = var.canary_role_arn
  handler              = "heartbeat.handler"
  zip_file             = "canary_script.zip"
  runtime_version      = "syn-nodejs-puppeteer-3.4"

  schedule {
    expression = "rate(5 minutes)"
  }
}
