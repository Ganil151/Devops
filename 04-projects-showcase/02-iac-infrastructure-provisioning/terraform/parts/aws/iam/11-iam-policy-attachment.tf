# 11. IAM Policy Attachment
# managing the relationship between a policy and a target (user, group, or role).

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  users      = [aws_iam_user.standard_user.name]
  roles      = [aws_iam_role.ec2_role.name]
  groups     = [aws_iam_group.developers.name]
  policy_arn = aws_iam_policy.s3_read_only.arn
}

# (Note: Prefer aws_iam_user_policy_attachment, aws_iam_group_policy_attachment, 
# or aws_iam_role_policy_attachment for finer control)
