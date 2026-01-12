# Elastic Container Registry (ECR) - Basics

Amazon Elastic Container Registry (Amazon ECR) is a fully managed container registry that makes it easy to store, manage, share, and deploy your container images and artifacts anywhere.

## Core Concepts

### What is ECR?
- **Repositories**: A place to store your Docker images.
- **Images**: Docker containers pushed to the registry.
- **Authorization Token**: Required to authenticate your Docker client with the registry.

## Getting Started

### 1. Create a Repository

```bash
aws ecr create-repository \
    --repository-name my-demo-app \
    --image-scanning-configuration scanOnPush=true \
    --region us-east-1
```

### 2. Authenticate Docker to ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### 3. Tag and Push an Image

```bash
# Tag your local image
docker tag my-image:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-demo-app:latest

# Push to ECR
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-demo-app:latest
```

### 4. Pull an Image

```bash
docker pull 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-demo-app:latest
```
