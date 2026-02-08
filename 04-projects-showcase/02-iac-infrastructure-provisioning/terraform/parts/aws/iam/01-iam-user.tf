# 01. Basic IAM User
# A standard user account with an access key.

resource "aws_iam_user" "standard_user" {
  name = "dev-user"
  path = "/system/"

  tags = {
    Department = "DevOps"
  }
}

resource "aws_iam_access_key" "standard_user_key" {
  user = aws_iam_user.standard_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.standard_user_key.id
}
# (Note: Secret key is sensitive, handle with care)
