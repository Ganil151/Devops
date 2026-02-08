# 19. EventBridge API Destination
# sending events directly to third-party SaaS APIs (e.g., Zendesk, Datadog, Slack).

resource "aws_cloudwatch_event_api_destination" "slack" {
  name                             = "slack-api-destination"
  description                      = "Send events to Slack Webhook"
  invocation_endpoint              = "https://hooks.slack.com/services/..."
  http_method                      = "POST"
  connection_arn                   = aws_cloudwatch_event_connection.slack.arn
}

resource "aws_cloudwatch_event_connection" "slack" {
  name               = "slack-connection"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "x-slack-header"
      value = "secret-token"
    }
  }
}
