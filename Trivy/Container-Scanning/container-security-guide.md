# Container Security with Trivy

## Container Image Scanning

### Docker Images
```bash
# Scan latest tag
trivy image nginx:latest

# Scan specific version
trivy image nginx:1.21-alpine

# Scan with authentication
trivy image --username $DOCKER_USER --password $DOCKER_PASS private-registry.com/app:v1.0

# Scan tar archive
trivy image --input image.tar
```

### Registry Integration
```bash
# AWS ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com
trivy image 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:latest

# Google Container Registry
trivy image gcr.io/project-id/image:tag

# Azure Container Registry
trivy image myregistry.azurecr.io/image:tag
```

### Vulnerability Analysis
```bash
# High and Critical only
trivy image --severity HIGH,CRITICAL nginx:latest

# Specific vulnerability types
trivy image --vuln-type os nginx:latest
trivy image --vuln-type library node:16

# Ignore unfixed vulnerabilities
trivy image --ignore-unfixed nginx:latest
```

## Container Runtime Security

### Running Container Scanning
```bash
# Scan running container
docker ps
trivy image $(docker inspect container_name --format='{{.Config.Image}}')

# Scan all running containers
for container in $(docker ps --format "table {{.Names}}" | tail -n +2); do
  echo "Scanning $container..."
  image=$(docker inspect $container --format='{{.Config.Image}}')
  trivy image $image
done
```

### Dockerfile Scanning
```bash
# Scan Dockerfile
trivy config --file-patterns dockerfile:Dockerfile .

# Scan with custom patterns
trivy config --file-patterns dockerfile:Dockerfile* .

# Example Dockerfile issues detected:
# - Running as root user
# - Using latest tags
# - Missing health checks
# - Exposed sensitive ports
```

## Multi-Stage Build Security

### Scanning Build Stages
```bash
# Build and scan each stage
docker build --target builder -t myapp:builder .
trivy image myapp:builder

docker build --target runtime -t myapp:runtime .
trivy image myapp:runtime
```

### Example Secure Dockerfile
```dockerfile
# Multi-stage build with security best practices
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:16-alpine AS runtime
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
WORKDIR /app
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --chown=nextjs:nodejs . .
USER nextjs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
CMD ["npm", "start"]
```

## Container Compliance

### CIS Benchmarks
```bash
# Scan against CIS Docker Benchmark
trivy image --compliance docker-cis nginx:latest

# Generate compliance report
trivy image --format json --compliance docker-cis --output cis-report.json nginx:latest
```

### Custom Policies
```yaml
# custom-policy.yaml
package trivy

deny[msg] {
  input.Config.User == "root"
  msg := "Container should not run as root user"
}

deny[msg] {
  input.Config.ExposedPorts["22/tcp"]
  msg := "SSH port should not be exposed"
}
```

```bash
# Use custom policy
trivy image --policy custom-policy.yaml nginx:latest
```

## Registry Security Automation

### Webhook Integration
```bash
#!/bin/bash
# Registry webhook handler

IMAGE_NAME=$1
IMAGE_TAG=$2

echo "Scanning pushed image: $IMAGE_NAME:$IMAGE_TAG"

# Scan image
SCAN_RESULT=$(trivy image --format json --quiet $IMAGE_NAME:$IMAGE_TAG)

# Check for critical vulnerabilities
CRITICAL_COUNT=$(echo $SCAN_RESULT | jq '.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL") | length')

if [ "$CRITICAL_COUNT" -gt 0 ]; then
  echo "CRITICAL vulnerabilities found. Blocking deployment."
  # Send alert to Slack/Teams
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"🚨 Critical vulnerabilities found in $IMAGE_NAME:$IMAGE_TAG\"}" \
    $SLACK_WEBHOOK_URL
  exit 1
fi

echo "Image security scan passed"
```

## Performance Optimization

### Caching Strategies
```bash
# Use persistent cache
export TRIVY_CACHE_DIR=/var/cache/trivy

# Skip database update for faster scans
trivy image --skip-update nginx:latest

# Offline scanning
trivy image --offline nginx:latest
```

### Parallel Scanning
```bash
#!/bin/bash
# Parallel image scanning

images=("nginx:latest" "redis:alpine" "postgres:13")

for image in "${images[@]}"; do
  {
    echo "Scanning $image..."
    trivy image --format json --output "${image//[:\/]/_}.json" $image
  } &
done

wait
echo "All scans completed"
```