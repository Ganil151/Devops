# 15. IAM Virtual MFA Device
# Provisioning MFA devices for users.

resource "aws_iam_virtual_mfa_device" "example" {
  virtual_mfa_device_name = "example-mfa-device"
}

# (Note: Enrollment usually happens via the AWS Console or CLI by the user)
