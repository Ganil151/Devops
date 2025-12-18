# Elastic Container Registry (ECR) - Intermediate

This guide covers lifecycle management, security scanning, and integrating ECR with orchestration services.

## Lifecycle Policies

Automate the cleanup of old images to manage costs.

```json
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
```

```bash
aws ecr put-lifecycle-policy \
    --repository-name my-demo-app \
    --lifecycle-policy-text file://policy.json
```

## Image Scanning

ECR uses Clair/Inspector to scan images for vulnerabilities (CVEs).

```bash
# Start a manual scan
aws ecr start-image-scan \
    --repository-name my-demo-app \
    --image-id imageTag=latest

# Retrieve findings
aws ecr describe-image-scan-findings \
    --repository-name my-demo-app \
    --image-id imageTag=latest
```

## Integration with ECS and EKS

### ECS (Elastic Container Service)
Ensure your ECS Task Execution Role has the `AmazonECSTaskExecutionRolePolicy` attached, which grants permissions to pull from ECR.

### EKS (Elastic Kubernetes Service)
When using EKS, worker nodes need permissions to pull images.
- If nodes are in the same account: Managed Node Groups automatically have this permission via the node IAM role.
- If pulling from a different account: You must configure a repository policy on the ECR repo to allow the EKS node role.
