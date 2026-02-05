## AWS Commands

### EC2-Instance Terminal Commands

#### Termination of EC2-Instance

```bash
# Step 1: Get instance IDs
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=K8s-Master-Server" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=K8s-Worker-Server" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text

# Step 2: Terminate instances (replace with actual IDs)
aws ec2 terminate-instances --instance-ids i-xxxxxxxxx i-yyyyyyyyy
```
