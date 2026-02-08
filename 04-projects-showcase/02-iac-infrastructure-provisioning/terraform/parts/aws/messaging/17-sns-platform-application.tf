# 17. SNS Platform Application (Mobile Push)
# enabling push notifications for iOS (APNS) or Android (FCM).

resource "aws_sns_platform_application" "fcm_app" {
  name     = "android_fcm_app"
  platform = "GCM"
  attributes = {
    PlatformCredential = var.fcm_server_key
  }
}
