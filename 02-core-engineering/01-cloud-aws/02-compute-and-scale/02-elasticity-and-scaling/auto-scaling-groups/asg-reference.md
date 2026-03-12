# Auto Scaling Groups (ASG) & VM Scale Sets (VMSS)

Auto Scaling ensures that you have the right number of instances to handle the load on your application.

## 🚀 Key Concepts
- **Desired Capacity**: The number of instances the group should maintain.
- **Minimum Size**: The lowest number of instances the group can scale down to.
- **Maximum Size**: The highest number of instances the group can scale up to.
- **Launch Template**: Defines the OS, instance type, and networking for new instances.

## ☁️ Provider Equivalents
- **AWS**: [Auto Scaling Groups](https://aws.amazon.com/autoscaling/)
- **Azure**: [Virtual Machine Scale Sets (VMSS)](https://azure.microsoft.com/en-us/products/virtual-machine-scale-sets/)
- **GCP**: [Managed Instance Groups (MIG)](https://cloud.google.com/compute/docs/instance-groups)

## 🛠️ IaC Implementation
```hcl
# AWS Example
resource "aws_autoscaling_group" "example" {
  max_size = 10
  min_size = 2
  # ... other configs
}
```
