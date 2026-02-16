# EKS Security and Networking Guide

## Table of Contents
1. [Security Architecture](#security-architecture)
2. [Identity and Access Management](#identity-and-access-management)
3. [Network Security](#network-security)
4. [Pod Security](#pod-security)
5. [Secrets Management](#secrets-management)
6. [Image Security](#image-security)
7. [Compliance and Auditing](#compliance-and-auditing)
8. [Network Policies](#network-policies)
9. [Service Mesh Security](#service-mesh-security)
10. [Security Monitoring](#security-monitoring)

## Security Architecture

### EKS Security Model
```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Account Boundary                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 EKS Control Plane                   │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   API       │  │    etcd     │  │ Controller  │ │   │
│  │  │   Server    │  │ (Encrypted) │  │   Manager   │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                    ┌─────────────┐                         │
│                    │   AWS IAM   │                         │
│                    │ Integration │                         │
│                    └─────────────┘                         │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    VPC Network                      │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Private   │  │   Private   │  │   Private   │ │   │
│  │  │   Subnet    │  │   Subnet    │  │   Subnet    │ │   │
│  │  │             │  │             │  │             │ │   │
│  │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │ │   │
│  │  │ │ Worker  │ │  │ │ Worker  │ │  │ │ Worker  │ │ │   │
│  │  │ │  Nodes  │ │  │ │  Nodes  │ │  │ │  Nodes  │ │ │   │
│  │  │ │   +SG   │ │  │ │   +SG   │ │  │ │   +SG   │ │ │   │
│  │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Security Layers
1. **AWS Account Security**: IAM, Organizations, SCPs
2. **Network Security**: VPC, Security Groups, NACLs
3. **Cluster Security**: RBAC, Pod Security Standards
4. **Container Security**: Image scanning, Runtime security
5. **Application Security**: Secrets, TLS, Authentication

## Identity and Access Management

### EKS Cluster IAM Roles
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Node Group IAM Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DescribeVpcs",
        "eks:DescribeCluster"
      ],
      "Resource": "*"
    }
  ]
}
```

### IRSA (IAM Roles for Service Accounts)
```yaml
# service-account-with-irsa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT-ID:role/AmazonEKSLoadBalancerControllerRole
automountServiceAccountToken: true

---
# Pod using IRSA
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-aws-access
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app-with-aws-access
  template:
    metadata:
      labels:
        app: app-with-aws-access
    spec:
      serviceAccountName: aws-s3-access-sa
      containers:
      - name: app
        image: myapp:v1.0.0
        env:
        - name: AWS_REGION
          value: us-west-2
        - name: AWS_ROLE_ARN
          value: arn:aws:iam::ACCOUNT-ID:role/S3AccessRole
        - name: AWS_WEB_IDENTITY_TOKEN_FILE
          value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

### RBAC Configuration
```yaml
# rbac-configuration.yaml
# Namespace-scoped role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]

---
# Cluster-scoped role for monitoring
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-role
rules:
- apiGroups: [""]
  resources: ["nodes", "nodes/proxy", "services", "endpoints", "pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["extensions"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]

---
# Role binding for developers
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: production
subjects:
- kind: User
  name: developer@company.com
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io

---
# Cluster role binding for monitoring
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: monitoring-binding
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
roleRef:
  kind: ClusterRole
  name: monitoring-role
  apiGroup: rbac.authorization.k8s.io
```

### AWS Auth ConfigMap
```yaml
# aws-auth-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::ACCOUNT-ID:role/NodeInstanceRole
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::ACCOUNT-ID:role/EKSAdminRole
      username: eks-admin
      groups:
        - system:masters
  mapUsers: |
    - userarn: arn:aws:iam::ACCOUNT-ID:user/developer1
      username: developer1
      groups:
        - developers
    - userarn: arn:aws:iam::ACCOUNT-ID:user/devops-engineer
      username: devops-engineer
      groups:
        - system:masters
  mapAccounts: |
    - "ACCOUNT-ID-1"
    - "ACCOUNT-ID-2"
```

## Network Security

### VPC Security Configuration
```yaml
# vpc-security-terraform.tf
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "eks-vpc"
    "kubernetes.io/cluster/production-cluster" = "shared"
  }
}

# Private subnets for worker nodes
resource "aws_subnet" "private_subnets" {
  count             = 3
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/production-cluster" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Public subnets for load balancers
resource "aws_subnet" "public_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.${count.index + 101}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/production-cluster" = "owned"
    "kubernetes.io/role/elb" = "1"
  }
}
```

### Security Groups
```yaml
# security-groups.tf
# Control plane security group
resource "aws_security_group" "cluster_sg" {
  name_prefix = "eks-cluster-sg"
  vpc_id      = aws_vpc.eks_vpc.id
  
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.eks_vpc.cidr_block]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "eks-cluster-sg"
  }
}

# Worker node security group
resource "aws_security_group" "node_sg" {
  name_prefix = "eks-node-sg"
  vpc_id      = aws_vpc.eks_vpc.id
  
  ingress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }
  
  ingress {
    description     = "Control plane to nodes"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster_sg.id]
  }
  
  ingress {
    description     = "Control plane to nodes HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster_sg.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "eks-node-sg"
  }
}

# Additional security group for specific applications
resource "aws_security_group" "app_sg" {
  name_prefix = "eks-app-sg"
  vpc_id      = aws_vpc.eks_vpc.id
  
  ingress {
    description = "HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  
  ingress {
    description = "HTTPS from ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  
  tags = {
    Name = "eks-app-sg"
  }
}
```

### Network ACLs
```yaml
# network-acls.tf
resource "aws_network_acl" "private_nacl" {
  vpc_id     = aws_vpc.eks_vpc.id
  subnet_ids = aws_subnet.private_subnets[*].id
  
  # Allow inbound traffic from VPC
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.eks_vpc.cidr_block
    from_port  = 0
    to_port    = 0
  }
  
  # Allow outbound traffic
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  
  tags = {
    Name = "private-nacl"
  }
}
```

## Pod Security

### Pod Security Standards
```yaml
# pod-security-standards.yaml
# Restricted namespace
apiVersion: v1
kind: Namespace
metadata:
  name: secure-production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted

---
# Baseline namespace
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted

---
# Secure pod deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: secure-production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      # Pod security context
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 3000
        fsGroup: 2000
        seccompProfile:
          type: RuntimeDefault
      
      containers:
      - name: app
        image: myapp:v1.0.0
        
        # Container security context
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
            add:
            - NET_BIND_SERVICE
        
        # Resource limits
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        
        # Volume mounts for writable directories
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: var-run
          mountPath: /var/run
        
        # Environment variables
        env:
        - name: PORT
          value: "8080"
      
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: var-run
        emptyDir: {}
```

### Security Context Constraints
```yaml
# security-context-constraints.yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: restricted-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: null
defaultAddCapabilities: null
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1
    max: 65535
readOnlyRootFilesystem: true
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: MustRunAs
  ranges:
  - min: 1
    max: 65535
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## Secrets Management

### Kubernetes Secrets
```yaml
# secrets-management.yaml
# Opaque secret
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: production
type: Opaque
data:
  database-url: cG9zdGdyZXM6Ly91c2VyOnBhc3NAaG9zdDo1NDMyL2RiCg==
  api-key: YWJjZGVmZ2hpams=

---
# TLS secret
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
  namespace: production
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi... # Base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi... # Base64 encoded private key

---
# Docker registry secret
apiVersion: v1
kind: Secret
metadata:
  name: registry-secret
  namespace: production
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJyZWdpc3RyeS5leGFtcGxlLmNvbSI6eyJ1c2VybmFtZSI6InVzZXIiLCJwYXNzd29yZCI6InBhc3MiLCJhdXRoIjoiZFhObGNqcHdZWE56In19fQ==
```

### AWS Secrets Manager Integration
```yaml
# secrets-store-csi.yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: app-secrets-provider
  namespace: production
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "prod/database/credentials"
        objectType: "secretsmanager"
        jmesPath:
          - path: "username"
            objectAlias: "db-username"
          - path: "password"
            objectAlias: "db-password"
      - objectName: "prod/api/keys"
        objectType: "secretsmanager"
        jmesPath:
          - path: "api-key"
            objectAlias: "api-key"

---
# Pod using secrets from AWS Secrets Manager
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-secrets
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app-with-secrets
  template:
    metadata:
      labels:
        app: app-with-secrets
    spec:
      serviceAccountName: secrets-manager-sa
      containers:
      - name: app
        image: myapp:v1.0.0
        env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: db-username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: db-password
        volumeMounts:
        - name: secrets-store
          mountPath: "/mnt/secrets"
          readOnly: true
      volumes:
      - name: secrets-store
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "app-secrets-provider"
```

### External Secrets Operator
```yaml
# external-secrets.yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets-manager
  namespace: production
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-west-2
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa

---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-external-secret
  namespace: production
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: app-secrets
    creationPolicy: Owner
  data:
  - secretKey: database-url
    remoteRef:
      key: prod/database/credentials
      property: url
  - secretKey: api-key
    remoteRef:
      key: prod/api/keys
      property: api-key
```

## Image Security

### Image Scanning with ECR
```bash
#!/bin/bash
# image-security-scan.sh

set -e

REPOSITORY_NAME="myapp"
IMAGE_TAG="v1.0.0"
REGION="us-west-2"

echo "Scanning image for vulnerabilities..."

# Start image scan
aws ecr start-image-scan \
    --repository-name $REPOSITORY_NAME \
    --image-id imageTag=$IMAGE_TAG \
    --region $REGION

# Wait for scan to complete
echo "Waiting for scan to complete..."
while true; do
    SCAN_STATUS=$(aws ecr describe-image-scan-findings \
        --repository-name $REPOSITORY_NAME \
        --image-id imageTag=$IMAGE_TAG \
        --region $REGION \
        --query 'imageScanStatus.status' \
        --output text 2>/dev/null || echo "IN_PROGRESS")
    
    if [ "$SCAN_STATUS" = "COMPLETE" ]; then
        break
    elif [ "$SCAN_STATUS" = "FAILED" ]; then
        echo "Scan failed"
        exit 1
    fi
    
    sleep 10
done

# Get scan results
CRITICAL_COUNT=$(aws ecr describe-image-scan-findings \
    --repository-name $REPOSITORY_NAME \
    --image-id imageTag=$IMAGE_TAG \
    --region $REGION \
    --query 'imageScanFindings.findingCounts.CRITICAL' \
    --output text)

HIGH_COUNT=$(aws ecr describe-image-scan-findings \
    --repository-name $REPOSITORY_NAME \
    --image-id imageTag=$IMAGE_TAG \
    --region $REGION \
    --query 'imageScanFindings.findingCounts.HIGH' \
    --output text)

echo "Critical vulnerabilities: ${CRITICAL_COUNT:-0}"
echo "High vulnerabilities: ${HIGH_COUNT:-0}"

# Fail if critical vulnerabilities found
if [ "${CRITICAL_COUNT:-0}" -gt 0 ]; then
    echo "Critical vulnerabilities found. Deployment blocked."
    exit 1
fi

echo "Image security scan passed"
```

### Admission Controllers
```yaml
# opa-gatekeeper.yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredsecuritycontext
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredSecurityContext
      validation:
        openAPIV3Schema:
          type: object
          properties:
            runAsNonRoot:
              type: boolean
            readOnlyRootFilesystem:
              type: boolean
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredsecuritycontext
        
        violation[{"msg": msg}] {
            container := input.review.object.spec.containers[_]
            not container.securityContext.runAsNonRoot
            msg := "Container must run as non-root user"
        }
        
        violation[{"msg": msg}] {
            container := input.review.object.spec.containers[_]
            not container.securityContext.readOnlyRootFilesystem
            msg := "Container must have read-only root filesystem"
        }

---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredSecurityContext
metadata:
  name: must-have-security-context
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
    namespaces: ["production", "staging"]
  parameters:
    runAsNonRoot: true
    readOnlyRootFilesystem: true
```

## Compliance and Auditing

### Audit Logging Configuration
```yaml
# audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
# Log all requests at the Metadata level
- level: Metadata
  # Don't log watch requests by the "system:kube-proxy" on endpoints or services
  omitStages:
    - RequestReceived
  resources:
  - group: ""
    resources: ["endpoints", "services"]
  namespaces: ["kube-system"]
  users: ["system:kube-proxy"]

# Log the request body of configmap changes in kube-system
- level: Request
  resources:
  - group: ""
    resources: ["configmaps"]
  namespaces: ["kube-system"]

# Log configmap and secret changes in all other namespaces at the Metadata level
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]

# Log all other resources in core and extensions at the Request level
- level: Request
  resources:
  - group: ""
  - group: "extensions"

# A catch-all rule to log all other requests at the Metadata level
- level: Metadata
  # Long-running requests like watches that fall under this rule will not
  # generate an audit event in RequestReceived.
  omitStages:
    - RequestReceived
```

### Falco Security Monitoring
```yaml
# falco-deployment.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: falco
  namespace: falco-system
spec:
  selector:
    matchLabels:
      app: falco
  template:
    metadata:
      labels:
        app: falco
    spec:
      serviceAccount: falco
      hostNetwork: true
      hostPID: true
      containers:
      - name: falco
        image: falcosecurity/falco:0.35.1
        securityContext:
          privileged: true
        args:
          - /usr/bin/falco
          - --cri=/run/containerd/containerd.sock
          - --k8s-api=https://kubernetes.default.svc
          - --k8s-api-cert=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          - --k8s-api-token=/var/run/secrets/kubernetes.io/serviceaccount/token
        volumeMounts:
        - mountPath: /host/var/run/docker.sock
          name: docker-socket
        - mountPath: /host/run/containerd/containerd.sock
          name: containerd-socket
        - mountPath: /host/dev
          name: dev-fs
        - mountPath: /host/proc
          name: proc-fs
          readOnly: true
        - mountPath: /host/boot
          name: boot-fs
          readOnly: true
        - mountPath: /host/lib/modules
          name: lib-modules
          readOnly: true
        - mountPath: /host/usr
          name: usr-fs
          readOnly: true
        - mountPath: /host/etc
          name: etc-fs
          readOnly: true
      volumes:
      - name: docker-socket
        hostPath:
          path: /var/run/docker.sock
      - name: containerd-socket
        hostPath:
          path: /run/containerd/containerd.sock
      - name: dev-fs
        hostPath:
          path: /dev
      - name: proc-fs
        hostPath:
          path: /proc
      - name: boot-fs
        hostPath:
          path: /boot
      - name: lib-modules
        hostPath:
          path: /lib/modules
      - name: usr-fs
        hostPath:
          path: /usr
      - name: etc-fs
        hostPath:
          path: /etc
```

## Network Policies

### Comprehensive Network Policies
```yaml
# network-policies.yaml
# Default deny all ingress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress

---
# Default deny all egress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress

---
# Allow frontend to backend communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080

---
# Allow backend to database communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-to-database
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  # Allow DNS resolution
  - to: []
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53

---
# Allow ingress controller to frontend
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-to-frontend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 3000

---
# Allow monitoring access
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: monitoring-access
  namespace: production
spec:
  podSelector:
    matchLabels:
      monitoring: "true"
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 9090
```

### Calico Network Policies
```yaml
# calico-network-policies.yaml
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: advanced-security-policy
  namespace: production
spec:
  selector: app == 'web-app'
  types:
  - Ingress
  - Egress
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: app == 'frontend'
    destination:
      ports:
      - 8080
  - action: Deny
    protocol: TCP
    source:
      nets:
      - 192.168.1.0/24
  egress:
  - action: Allow
    protocol: TCP
    destination:
      selector: app == 'database'
      ports:
      - 5432
  - action: Allow
    protocol: UDP
    destination:
      ports:
      - 53
  - action: Deny
    destination: {}

---
# Global network policy
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: deny-all-non-system-traffic
spec:
  selector: projectcalico.org/namespace != "kube-system"
  types:
  - Ingress
  - Egress
  ingress:
  - action: Deny
    source: {}
  egress:
  - action: Deny
    destination: {}
```

## Service Mesh Security

### Istio Security Configuration
```yaml
# istio-security.yaml
# PeerAuthentication for mTLS
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT

---
# AuthorizationPolicy for access control
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: frontend-policy
  namespace: production
spec:
  selector:
    matchLabels:
      app: frontend
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account"]
  - to:
    - operation:
        methods: ["GET", "POST"]

---
# RequestAuthentication for JWT validation
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: jwt-auth
  namespace: production
spec:
  selector:
    matchLabels:
      app: api-server
  jwtRules:
  - issuer: "https://auth.example.com"
    jwksUri: "https://auth.example.com/.well-known/jwks.json"
    audiences:
    - "api.example.com"

---
# DestinationRule for TLS
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend-tls
  namespace: production
spec:
  host: backend.production.svc.cluster.local
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
```

## Security Monitoring

### Security Monitoring Stack
```yaml
# security-monitoring.yaml
# Prometheus rules for security monitoring
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: security-rules
  namespace: monitoring
spec:
  groups:
  - name: security.rules
    rules:
    - alert: PodSecurityViolation
      expr: increase(falco_events_total{rule_name=~".*security.*"}[5m]) > 0
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: "Security violation detected"
        description: "Falco detected a security violation: {{ $labels.rule_name }}"
    
    - alert: UnauthorizedAPIAccess
      expr: increase(apiserver_audit_total{verb!~"get|list|watch"}[5m]) > 100
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "High number of unauthorized API access attempts"
        description: "Detected {{ $value }} unauthorized API access attempts in the last 5 minutes"
    
    - alert: PrivilegedPodCreated
      expr: increase(kube_pod_container_status_running{container=~".*privileged.*"}[5m]) > 0
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: "Privileged pod created"
        description: "A privileged pod was created: {{ $labels.pod }}"

---
# Grafana dashboard for security metrics
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-dashboard
  namespace: monitoring
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "EKS Security Dashboard",
        "panels": [
          {
            "title": "Security Events",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(falco_events_total[5m])",
                "legendFormat": "{{ rule_name }}"
              }
            ]
          },
          {
            "title": "Failed Authentication Attempts",
            "type": "stat",
            "targets": [
              {
                "expr": "sum(rate(apiserver_audit_total{verb=\"create\",objectRef_resource=\"tokenreviews\",code!~\"2..\"}[5m]))"
              }
            ]
          }
        ]
      }
    }
```

### Security Scanning Automation
```bash
#!/bin/bash
# security-scan-automation.sh

set -e

NAMESPACE="production"
CLUSTER_NAME="production-cluster"

echo "Starting security scan automation..."

# 1. Scan for privileged containers
echo "Checking for privileged containers..."
kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].securityContext.privileged}{"\n"}{end}' | grep -i true && echo "WARNING: Privileged containers found" || echo "OK: No privileged containers"

# 2. Check for containers running as root
echo "Checking for containers running as root..."
kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].securityContext.runAsUser}{"\n"}{end}' | grep -E "\t0$|\t$" && echo "WARNING: Containers running as root found" || echo "OK: No containers running as root"

# 3. Check for missing resource limits
echo "Checking for missing resource limits..."
kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources.limits}{"\n"}{end}' | grep -E "\t$|\tnull$" && echo "WARNING: Containers without resource limits found" || echo "OK: All containers have resource limits"

# 4. Check for network policies
echo "Checking for network policies..."
NETPOL_COUNT=$(kubectl get networkpolicy -n $NAMESPACE --no-headers | wc -l)
if [ "$NETPOL_COUNT" -eq 0 ]; then
    echo "WARNING: No network policies found"
else
    echo "OK: $NETPOL_COUNT network policies found"
fi

# 5. Check for secrets in environment variables
echo "Checking for secrets in environment variables..."
kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].env[*].name}{"\n"}{end}' | grep -iE "password|secret|key|token" && echo "WARNING: Potential secrets in environment variables" || echo "OK: No obvious secrets in environment variables"

# 6. Generate security report
cat > security-report.json << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "cluster": "$CLUSTER_NAME",
  "namespace": "$NAMESPACE",
  "scans": {
    "privileged_containers": $(kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.spec.containers[*].securityContext.privileged}{"\n"}{end}' | grep -c true || echo 0),
    "root_containers": $(kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.spec.containers[*].securityContext.runAsUser}{"\n"}{end}' | grep -cE "^0$|^$" || echo 0),
    "network_policies": $NETPOL_COUNT,
    "total_pods": $(kubectl get pods -n $NAMESPACE --no-headers | wc -l)
  }
}
EOF

echo "Security scan completed. Report saved to security-report.json"
```

## Best Practices Summary

### Security Checklist
- [ ] Enable Pod Security Standards
- [ ] Implement RBAC with least privilege
- [ ] Use IRSA for AWS service access
- [ ] Enable audit logging
- [ ] Implement network policies
- [ ] Scan container images for vulnerabilities
- [ ] Use secrets management (AWS Secrets Manager/Parameter Store)
- [ ] Enable encryption at rest and in transit
- [ ] Monitor security events with Falco
- [ ] Regular security assessments
- [ ] Implement admission controllers
- [ ] Use service mesh for advanced security (optional)

### Network Security Checklist
- [ ] Private subnets for worker nodes
- [ ] Proper security group configuration
- [ ] Network ACLs for additional security
- [ ] VPC Flow Logs enabled
- [ ] Private API server endpoint (if required)
- [ ] WAF for public-facing applications
- [ ] DDoS protection with AWS Shield

### Compliance Considerations
- [ ] SOC 2 compliance requirements
- [ ] PCI DSS for payment processing
- [ ] HIPAA for healthcare data
- [ ] GDPR for EU data protection
- [ ] Regular compliance audits
- [ ] Data encryption requirements
- [ ] Access logging and monitoring

This comprehensive security and networking guide provides the foundation for securing EKS clusters in production environments with defense-in-depth strategies.