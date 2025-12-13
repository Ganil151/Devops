# Container Security

Complete guide to container security practices and tools.

## Container Image Security

### Image Scanning
```bash
# Trivy Scanning
trivy image nginx:latest
trivy image --format json --output results.json myapp:latest

# Clair Scanner
clair-scanner --ip localhost myapp:latest

# Snyk Container Scanning
snyk container test myapp:latest
snyk container monitor myapp:latest
```

### Secure Dockerfile Practices
```dockerfile
# Multi-stage build
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS runtime
# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Security configurations
USER nextjs
EXPOSE 3000
ENV NODE_ENV=production

# Remove unnecessary packages
RUN apk del --purge build-dependencies

CMD ["npm", "start"]
```

## Runtime Security

### Kubernetes Security Policies
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
```

### Container Runtime Security
```bash
# Docker Security Options
docker run --security-opt=no-new-privileges \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --read-only \
  --tmpfs /tmp \
  myapp:latest

# Falco Runtime Security
# /etc/falco/falco_rules.yaml
- rule: Detect shell in container
  desc: Detect shell spawned in container
  condition: >
    spawned_process and container and
    (proc.name in (shell_binaries))
  output: >
    Shell spawned in container (user=%user.name container_id=%container.id 
    image=%container.image.repository proc=%proc.cmdline)
  priority: WARNING
```

## Image Hardening

### Base Image Security
```dockerfile
# Use minimal base images
FROM scratch
FROM alpine:latest
FROM gcr.io/distroless/java:11

# Security scanning in build
FROM alpine:latest
RUN apk add --no-cache curl
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy
RUN trivy filesystem --exit-code 1 /
```

### Supply Chain Security
```bash
# Image signing with Cosign
cosign generate-key-pair
cosign sign --key cosign.key myregistry/myapp:latest

# Verify signed images
cosign verify --key cosign.pub myregistry/myapp:latest

# SBOM generation
syft packages myapp:latest -o spdx-json > sbom.json
grype sbom:sbom.json
```