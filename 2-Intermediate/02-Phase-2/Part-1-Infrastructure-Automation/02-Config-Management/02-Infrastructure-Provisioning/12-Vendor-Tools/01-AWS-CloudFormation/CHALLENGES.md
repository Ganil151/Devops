# 🛠️ CloudFormation Challenges

## Challenge 1: The Stack Update
**Objective**: Basic lifecycle.
1.  Deploy the `template.yaml` via AWS Console or CLI (`aws cloudformation create-stack`).
2.  Add a new resource: an `AWS::EC2::Instance`.
3.  Perform a stack update: `aws cloudformation update-stack`.
4.  View the "Events" tab to see the change set.

## Challenge 2: Intrinsic Functions
**Objective**: Advanced logic.
1.  Use `!Join` to create a complex string.
2.  Use `!If` to only create a resource if a specific parameter is set to `true`.
3.  Use `!GetAtt` to pass the IP of an EC2 instance to a security group.

## Challenge 3: Deletion Policy
**Objective**: Prevent data loss.
1.  Add `DeletionPolicy: Retain` to your S3 bucket.
2.  Delete the stack.
3.  Verify the bucket still exists in the S3 console.
