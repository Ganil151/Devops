# Kubernetes Pods

## Overview

**Kubernetes Pods** are the smallest deployable units in Kubernetes. A pod represents a single instance of a running process in a cluster and can contain one or more containers that share storage, network, and a specification for how to run the containers.

## What are Kubernetes Pods?

Kubernetes Pods are:
- The basic execution unit in Kubernetes
- A wrapper around one or more containers
- Ephemeral and disposable by design
- The unit of scaling, deployment, and replication

## Pod Architecture

### Single Container Pod
```
┌─────────────────────────────────────────┐
│                Pod                      │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │         Container               │    │
│  │                                 │    │
│  │  ┌─────────────┐ ┌───────────┐  │    │
│  │  │ Application │ │  Volumes  │  │    │
│  │  └─────────────┘ └───────────┘  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Network: Pod IP (10.244.1.5)          │
│  Storage: Shared Volumes                │
└─────────────────────────────────────────┘
```

### Multi-Container Pod
```
┌─────────────────────────────────────────┐
│                Pod                      │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Container 1 │  │   Container 2   │   │
│  │   (Main)    │  │   (Sidecar)     │   │
│  │             │  │                 │   │
│  └─────────────┘  └─────────────────┘   │
│           │               │             │
│           └───────┬───────┘             │
│                   │                     │
│  ┌─────────────────────────────────┐    │
│  │      Shared Network & Storage   │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Network: Pod IP (10.244.1.5)          │
│  Storage: Shared Volumes                │
└─────────────────────────────────────────┘
```

## Pod Lifecycle

### Pod Phases
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Pending   │───►│   Running   │───►│ Succeeded/  │
│             │    │             │    │   Failed    │
└─────────────┘    └─────────────┘    └─────────────┘
       │                                      ▲
       │                                      │
       └──────────────────────────────────────┘
                    Unknown
```

### Pod Conditions
```yaml
status:
  conditions:
  - type: Initialized
    status: "True"
    reason: PodCompleted
  - type: Ready
    status: "True"
    reason: PodCompleted
  - type: ContainersReady
    status: "True"
    reason: PodCompleted
  - type: PodScheduled
    status: "True"
    reason: PodCompleted
```

## Basic Pod Configuration

### Simple Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.20
    ports:
    - containerPort: 80
```

### Pod with Resource Limits
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "512Mi"
```

### Multi-Container Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: web-server
    image: nginx:1.20
    ports:
    - containerPort: 80
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  - name: content-puller
    image: alpine/git
    command: ['sh', '-c', 'git clone https://github.com/example/content.git /data && sleep 3600']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```

## Container Patterns

### 1. Sidecar Pattern
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
spec:
  containers:
  - name: main-app
    image: myapp:latest
    volumeMounts:
    - name: logs
      mountPath: /var/log
  - name: log-shipper
    image: fluentd:latest
    volumeMounts:
    - name: logs
      mountPath: /var/log
  volumes:
  - name: logs
    emptyDir: {}
```

### 2. Ambassador Pattern
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ambassador-pod
spec:
  containers:
  - name: main-app
    image: myapp:latest
    env:
    - name: DATABASE_HOST
      value: "localhost"
    - name: DATABASE_PORT
      value: "5432"
  - name: ambassador
    image: postgres-proxy:latest
    ports:
    - containerPort: 5432
    env:
    - name: POSTGRES_HOST
      value: "postgres.example.com"
```

### 3. Adapter Pattern
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: adapter-pod
spec:
  containers:
  - name: main-app
    image: legacy-app:latest
    volumeMounts:
    - name: app-logs
      mountPath: /var/log/app
  - name: log-adapter
    image: log-formatter:latest
    volumeMounts:
    - name: app-logs
      mountPath: /var/log/app
    - name: formatted-logs
      mountPath: /var/log/formatted
  volumes:
  - name: app-logs
    emptyDir: {}
  - name: formatted-logs
    emptyDir: {}
```

## Pod Networking

### Pod IP Assignment
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: network-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
status:
  podIP: "10.244.1.5"
  podIPs:
  - ip: "10.244.1.5"
```

### Host Networking
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: host-network-pod
spec:
  hostNetwork: true
  containers:
  - name: app
    image: nginx:1.20
    ports:
    - containerPort: 80
      hostPort: 8080
```

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: pod-network-policy
spec:
  podSelector:
    matchLabels:
      app: secure-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## Pod Storage

### Volume Types

#### EmptyDir
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: cache-volume
      mountPath: /cache
  volumes:
  - name: cache-volume
    emptyDir:
      sizeLimit: 1Gi
```

#### HostPath
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: host-volume
      mountPath: /host-data
  volumes:
  - name: host-volume
    hostPath:
      path: /var/data
      type: Directory
```

#### ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    database.host=localhost
    database.port=5432
---
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
```

#### Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: MWYyZDFlMmU2N2Rm  # base64 encoded
---
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secret
```

#### Persistent Volume
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
spec:
  containers:
  - name: app
    image: postgres:13
    volumeMounts:
    - name: postgres-storage
      mountPath: /var/lib/postgresql/data
  volumes:
  - name: postgres-storage
    persistentVolumeClaim:
      claimName: app-pvc
```

## Pod Security

### Security Context
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.20
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
```

### Pod Security Standards
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: restricted-pod
  labels:
    pod-security.kubernetes.io/enforce: restricted
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.20
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### Service Account
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
---
apiVersion: v1
kind: Pod
metadata:
  name: serviceaccount-pod
spec:
  serviceAccountName: app-service-account
  containers:
  - name: app
    image: myapp:latest
```

## Pod Scheduling

### Node Selection

#### Node Selector
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-pod
spec:
  nodeSelector:
    disktype: ssd
    kubernetes.io/arch: amd64
  containers:
  - name: app
    image: nginx:1.20
```

#### Node Affinity
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/arch
            operator: In
            values: ["amd64"]
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values: ["ssd"]
  containers:
  - name: app
    image: nginx:1.20
```

#### Pod Affinity/Anti-Affinity
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-affinity-pod
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: database
        topologyKey: kubernetes.io/hostname
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app: web
          topologyKey: kubernetes.io/hostname
  containers:
  - name: app
    image: nginx:1.20
```

### Tolerations and Taints
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: toleration-pod
spec:
  tolerations:
  - key: "node-type"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  - key: "dedicated"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 3600
  containers:
  - name: app
    image: tensorflow/tensorflow:latest-gpu
```

## Pod Health Checks

### Liveness Probe
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
      successThreshold: 1
```

### Readiness Probe
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 3
      failureThreshold: 3
```

### Startup Probe
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-pod
spec:
  containers:
  - name: app
    image: slow-starting-app:latest
    startupProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 10
      failureThreshold: 30
    livenessProbe:
      tcpSocket:
        port: 8080
      periodSeconds: 10
```

## Pod Lifecycle Hooks

### PostStart and PreStop
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    lifecycle:
      postStart:
        exec:
          command:
          - /bin/sh
          - -c
          - echo "Container started" > /var/log/startup.log
      preStop:
        httpGet:
          path: /shutdown
          port: 8080
```

## Init Containers

### Basic Init Container
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting for mydb; sleep 2; done;']
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
```

### Init Container with Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-volume-pod
spec:
  initContainers:
  - name: init-data
    image: alpine/git
    command:
    - git
    - clone
    - https://github.com/example/data.git
    - /data
    volumeMounts:
    - name: workdir
      mountPath: /data
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  volumes:
  - name: workdir
    emptyDir: {}
```

## Pod Management

### Pod Operations

#### Create Pod
```bash
# From YAML file
kubectl apply -f pod.yaml

# Imperative creation
kubectl run nginx-pod --image=nginx:1.20 --port=80

# With environment variables
kubectl run env-pod --image=nginx:1.20 --env="ENV=production"

# Dry run
kubectl run test-pod --image=nginx:1.20 --dry-run=client -o yaml
```

#### View Pods
```bash
# List pods
kubectl get pods

# Detailed view
kubectl get pods -o wide

# Show labels
kubectl get pods --show-labels

# Filter by labels
kubectl get pods -l app=nginx

# Watch pods
kubectl get pods -w
```

#### Describe Pod
```bash
# Detailed pod information
kubectl describe pod nginx-pod

# Pod events
kubectl get events --field-selector involvedObject.name=nginx-pod

# Pod status
kubectl get pod nginx-pod -o jsonpath='{.status.phase}'
```

#### Pod Logs
```bash
# View logs
kubectl logs nginx-pod

# Follow logs
kubectl logs -f nginx-pod

# Previous container logs
kubectl logs nginx-pod --previous

# Multi-container pod logs
kubectl logs nginx-pod -c container-name

# All containers
kubectl logs nginx-pod --all-containers=true
```

#### Execute Commands
```bash
# Execute command
kubectl exec nginx-pod -- ls /app

# Interactive shell
kubectl exec -it nginx-pod -- /bin/bash

# Multi-container pod
kubectl exec -it nginx-pod -c container-name -- /bin/sh
```

#### Delete Pod
```bash
# Delete pod
kubectl delete pod nginx-pod

# Force delete
kubectl delete pod nginx-pod --force --grace-period=0

# Delete by label
kubectl delete pods -l app=nginx

# Delete all pods
kubectl delete pods --all
```

## Pod Troubleshooting

### Common Issues

#### 1. Pod Stuck in Pending
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check node resources
kubectl describe nodes

# Check scheduler logs
kubectl logs -n kube-system kube-scheduler-<master-node>
```

#### 2. Pod CrashLoopBackOff
```bash
# Check pod logs
kubectl logs <pod-name> --previous

# Check pod events
kubectl describe pod <pod-name>

# Check resource limits
kubectl describe pod <pod-name> | grep -A 10 "Limits:"
```

#### 3. ImagePullBackOff
```bash
# Check image name and tag
kubectl describe pod <pod-name>

# Check image pull secrets
kubectl get secrets

# Test image pull manually
crictl pull <image-name>
```

#### 4. Pod Not Ready
```bash
# Check readiness probe
kubectl describe pod <pod-name>

# Check service endpoints
kubectl get endpoints

# Test probe endpoint
kubectl exec <pod-name> -- curl localhost:8080/health
```

### Debug Commands
```bash
# Pod resource usage
kubectl top pod <pod-name>

# Pod network information
kubectl get pod <pod-name> -o jsonpath='{.status.podIP}'

# Pod node assignment
kubectl get pod <pod-name> -o jsonpath='{.spec.nodeName}'

# Pod containers
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}'
```

## Pod Best Practices

### 1. Resource Management
- Always set resource requests and limits
- Use appropriate QoS classes
- Monitor resource usage
- Implement resource quotas

### 2. Health Checks
- Configure liveness and readiness probes
- Use appropriate probe types
- Set proper timeouts and thresholds
- Test probe endpoints

### 3. Security
- Use non-root containers
- Implement security contexts
- Use read-only root filesystems
- Drop unnecessary capabilities

### 4. Configuration
- Use ConfigMaps and Secrets for configuration
- Avoid hardcoded values in images
- Use environment variables appropriately
- Implement proper logging

### 5. Networking
- Use services for pod communication
- Implement network policies
- Avoid host networking unless necessary
- Plan IP address allocation

## Pod Patterns and Use Cases

### Batch Processing
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: batch-job-pod
spec:
  restartPolicy: OnFailure
  containers:
  - name: batch-processor
    image: batch-app:latest
    command: ["python", "process_data.py"]
    resources:
      requests:
        cpu: "500m"
        memory: "1Gi"
      limits:
        cpu: "2"
        memory: "4Gi"
```

### Database Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database-pod
spec:
  containers:
  - name: postgres
    image: postgres:13
    env:
    - name: POSTGRES_DB
      value: myapp
    - name: POSTGRES_USER
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
    volumeMounts:
    - name: postgres-storage
      mountPath: /var/lib/postgresql/data
  volumes:
  - name: postgres-storage
    persistentVolumeClaim:
      claimName: postgres-pvc
```

## Conclusion

Kubernetes Pods are essential for:
- Running containerized applications in Kubernetes
- Providing shared networking and storage for containers
- Enabling various container patterns and architectures
- Supporting application lifecycle management
- Implementing security and resource policies

Understanding pod concepts, configuration, and management is fundamental to working effectively with Kubernetes and building robust containerized applications.