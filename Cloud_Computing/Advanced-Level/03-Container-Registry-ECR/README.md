# Elastic Container Registry (ECR) - Advanced Architecture

This guide covers cross-region replication, private connectivity, and advanced security configurations.

## Cross-Region Replication

Automatically replicate images to other regions or accounts for disaster recovery or lower latency.

```bash
# Configure replication
aws ecr put-replication-configuration \
    --replication-configuration file://replication-config.json
```

*replication-config.json example:*
```json
{
    "rules": [
        {
            "destinations": [
                {
                    "region": "us-west-2",
                    "registryId": "123456789012"
                }
            ]
        }
    ]
}
```

## Pull Through Cache Rules

Cache images from public registries (like Docker Hub or ECR Public) in your private ECR. This protects you from rate limits and upstream outages.

```bash
aws ecr create-pull-through-cache-rule \
    --ecr-repository-prefix docker-hub \
    --upstream-registry-url public.ecr.aws/docker/library
```

## Private Connectivity (VPC Endpoints)

Access ECR privately from your VPC without traversing the public internet.

Requires two types of endpoints:
1.  **Interface Endpoint for ECR API** (`com.amazonaws.region.ecr.api`)
2.  **Interface Endpoint for Docker Registry APIs** (`com.amazonaws.region.ecr.dkr`)
3.  *(Optional)* **Gateway Endpoint for S3** (Required because ECR stores layers in S3)

## Cross-Account Access

Allow a different AWS account to pull/push images.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::OTHER_ACCOUNT_ID:root"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]
}
```
