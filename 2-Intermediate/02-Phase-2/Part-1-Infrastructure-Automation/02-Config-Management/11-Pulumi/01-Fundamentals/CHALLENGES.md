# 🛠️ Pulumi Challenges

## Challenge 1: The First Stack
**Objective**: Deploy infra with code.
1.  Run `pulumi new aws-python`.
2.  Modify `__main__.py` to create a `aws_instance` (EC2).
3.  Run `pulumi up`.

## Challenge 2: Component Resources
**Objective**: Abstraction.
1.  Create a Python class `VpcNetwork` that inherits from `pulumi.ComponentResource`.
2.  Inside the class, define a VPC and two subnets.
3.  Instantiate the class in your `__main__.py`.

## Challenge 3: Crosswalk for AWS
**Objective**: Higher-level libraries.
1.  Use `pulumi_awsx`.
2.  Deploy an Application Load Balancer (ALB) with just a few lines of code.
3.  Notice how `awsx` handles the subnets and target groups automatically.
