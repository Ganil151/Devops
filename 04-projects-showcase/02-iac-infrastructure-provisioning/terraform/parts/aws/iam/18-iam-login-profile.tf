# 18. IAM User with Console Login
# Creating a user that can sign in to the AWS Management Console.

resource "aws_iam_user_login_profile" "example" {
  user    = aws_iam_user.standard_user.name
  pgp_key = "keybase:some_person" # Required to encrypt the initial password
}

output "password" {
  value = aws_iam_user_login_profile.example.encrypted_password
}
