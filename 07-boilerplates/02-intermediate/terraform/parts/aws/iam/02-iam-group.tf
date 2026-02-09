# 02. IAM Group and Membership
# managing permissions at scale by grouping users.

resource "aws_iam_group" "developers" {
  name = "developers-group"
  path = "/users/"
}

resource "aws_iam_group_membership" "dev_team" {
  name = "dev-group-membership"

  users = [
    aws_iam_user.standard_user.name,
  ]

  group = aws_iam_group.developers.name
}

resource "aws_iam_group_policy_attachment" "readonly" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
