# 18. EventBridge Custom Event Bus
# Isolating application events from the default system bus.

resource "aws_cloudwatch_event_bus" "app_bus" {
  name = "application-event-bus"
}
