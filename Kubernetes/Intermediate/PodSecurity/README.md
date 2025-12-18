# Kubernetes Pod Security

## Overview

**Kubernetes Pod Security** encompasses multiple mechanisms to secure pods at runtime, including Pod Security Standards, Security Contexts, and admission controls. These features prevent privilege escalation, enforce security policies, and protect the host system from malicious containers.

## Pod Security Standards (PSS)

### Security Levels

#### Privileged
```yaml
# No restrictions - allows known privilege escalations
apiVersion: v1
kind: Namespace
metadata:
  name: privileged-ns
  labels:
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/warn: privileged
```

#### Baseline
```yaml
# Minimally restrictive - prevents known privilege escalations
apiVersion: v1
kind: Namespace
metadata:
  name: baseline-ns
  labels:
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/audit: baseline
    pod-security.kubernetes.io/warn: baseline
```

#### Restricted
```yaml
# Heavily restricted - follows pod hardening best practices
apiVersion: v1
kind: Namespace
metadata:
  name: restricted-ns
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### Pod Security Configuration
```yaml
# Cluster-wide Pod Security configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: pod-security-config
  namespace: kube-system
data:
  config.yaml: |
    apiVersion: pod-security.admission.config.k8s.io/v1beta1
    kind: PodSecurityConfiguration
    defaults:
      enforce: "baseline"
      enforce-version: "latest"
      audit: "restricted"
      audit-version: "latest"
      warn: "restricted"
      warn-version: "latest"
    exemptions:
      usernames: []
      runtimeClasses: []
      namespaces: ["kube-system", "kube-public"]
```

## Security Contexts

### Pod-level Security Context
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    # Run as non-root user
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 3000
    # Set filesystem group
    fsGroup: 2000
    # Set supplemental groups
    supplementalGroups: [4000]
    # SELinux options
    seLinuxOptions:
      level: "s0:c123,c456"
    # Seccomp profile
    seccompProfile:
      type: RuntimeDefault
    # Sysctl settings
    sysctls:
    - name: net.core.somaxconn
      value: "1024"
  containers:
  - name: app
    image: nginx:1.21
```

### Container-level Security Context
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: container-security
spec:
  containers:
  - name: secure-container
    image: nginx:1.21
    securityContext:
      # Prevent privilege escalation
      allowPrivilegeEscalation: false
      # Drop all capabilities
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
      # Read-only root filesystem
      readOnlyRootFilesystem: true
      # Run as specific user
      runAsNonRoot: true
      runAsUser: 1001
      # Seccomp profile
      seccompProfile:
        type: RuntimeDefault
    volumeMounts:
    - name: tmp-volume
      mountPath: /tmp
    - name: var-cache
      mountPath: /var/cache/nginx
  volumes:
  - name: tmp-volume
    emptyDir: {}
  - name: var-cache
    emptyDir: {}
```

## Advanced Security Features

### AppArmor Integration
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apparmor-pod
  annotations:
    container.apparmor.security.beta.kubernetes.io/secure-container: localhost/k8s-apparmor-example-deny-write
spec:
  containers:
  - name: secure-container
    image: nginx:1.21
    securityContext:
      allowPrivilegeEscalation: false
```

### Seccomp Profiles
```yaml
# Custom seccomp profile
apiVersion: v1
kind: ConfigMap
metadata:
  name: seccomp-profile
data:
  profile.json: |
    {
      "defaultAction": "SCMP_ACT_ERRNO",
      "architectures": ["SCMP_ARCH_X86_64"],
      "syscalls": [
        {
          "names": ["read", "write", "open", "close", "stat", "fstat"],
          "action": "SCMP_ACT_ALLOW"
        }
      ]
    }
---
apiVersion: v1
kind: Pod
metadata:
  name: seccomp-pod
spec:
  securityContext:
    seccompProfile:
      type: Localhost
      localhostProfile: profiles/audit.json
  containers:
  - name: app
    image: nginx:1.21
```

### Capabilities Management
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: capabilities-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    securityContext:
      capabilities:
        # Drop all default capabilities
        drop:
        - ALL
        # Add only required capabilities
        add:
        - NET_BIND_SERVICE  # Bind to ports < 1024
        - CHOWN            # Change file ownership
```

## Resource Security

### Resource Limits and Requests
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-limited-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
        ephemeral-storage: "1Gi"
      limits:
        memory: "128Mi"
        cpu: "500m"
        ephemeral-storage: "2Gi"
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
```

### Pod Disruption Budgets
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: critical-app
```

## Admission Controllers

### Pod Security Policy (Deprecated)
```yaml
# Note: PSP is deprecated, use Pod Security Standards instead
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
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
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

### OPA Gatekeeper Policies
```yaml
# Gatekeeper ConstraintTemplate
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
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredsecuritycontext
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.runAsNonRoot
          msg := "Container must run as non-root user"
        }
---
# Gatekeeper Constraint
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredSecurityContext
metadata:
  name: must-run-as-nonroot
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaces: ["production"]
```

## Runtime Security

### Falco Security Monitoring
```yaml
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
        image: falcosecurity/falco:latest
        securityContext:
          privileged: true
        volumeMounts:
        - name: dev
          mountPath: /host/dev
        - name: proc
          mountPath: /host/proc
        - name: boot
          mountPath: /host/boot
        - name: lib-modules
          mountPath: /host/lib/modules
        - name: usr
          mountPath: /host/usr
        - name: etc
          mountPath: /host/etc
      volumes:
      - name: dev
        hostPath:
          path: /dev
      - name: proc
        hostPath:
          path: /proc
      - name: boot
        hostPath:
          path: /boot
      - name: lib-modules
        hostPath:
          path: /lib/modules
      - name: usr
        hostPath:
          path: /usr
      - name: etc
        hostPath:
          path: /etc
```

### Custom Falco Rules
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-rules
  namespace: falco-system
data:
  custom_rules.yaml: |
    - rule: Detect Shell in Container
      desc: Detect shell execution in container
      condition: >
        spawned_process and container and
        (proc.name in (shell_binaries) or
         proc.pname in (shell_binaries))
      output: >
        Shell spawned in container (user=%user.name container_id=%container.id
        container_name=%container.name shell=%proc.name parent=%proc.pname
        cmdline=%proc.cmdline)
      priority: WARNING
      tags: [container, shell]
    
    - rule: Sensitive File Access
      desc: Detect access to sensitive files
      condition: >
        open_read and container and
        (fd.name startswith /etc/passwd or
         fd.name startswith /etc/shadow or
         fd.name startswith /etc/ssh/)
      output: >
        Sensitive file accessed (user=%user.name container_id=%container.id
        file=%fd.name)
      priority: HIGH
      tags: [filesystem, sensitive]
```

## Image Security

### Image Scanning Integration
```yaml
# Trivy image scanner
apiVersion: batch/v1
kind: Job
metadata:
  name: image-scan
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: trivy
        image: aquasec/trivy:latest
        command: ["trivy"]
        args: 
        - "image"
        - "--exit-code"
        - "1"
        - "--severity"
        - "HIGH,CRITICAL"
        - "nginx:latest"
```

### Image Policy Webhook
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionWebhook
metadata:
  name: image-policy-webhook
webhooks:
- name: image-policy.example.com
  clientConfig:
    service:
      name: image-policy-service
      namespace: kube-system
      path: "/validate"
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  admissionReviewVersions: ["v1", "v1beta1"]
```

## Monitoring and Alerting

### Security Metrics
```yaml
# Prometheus monitoring rules
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: pod-security-rules
spec:
  groups:
  - name: pod-security
    rules:
    - alert: PrivilegedPodDetected
      expr: |
        kube_pod_container_status_running{container!="POD"} * on(pod, namespace) 
        kube_pod_spec_volumes_hostpath_path{path="/"}
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: "Privileged pod detected"
        description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is running with privileged access"
    
    - alert: RootUserDetected
      expr: |
        kube_pod_container_status_running * on(pod, namespace, container) 
        kube_pod_container_info{container_id!="",image!~".*pause.*"} * on(pod, namespace) 
        (kube_pod_spec_containers_security_context_run_as_user == 0)
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Container running as root user"
```

### Audit Logging
```yaml
# Audit policy for security events
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  namespaces: ["production"]
  verbs: ["create", "update", "patch"]
  resources:
  - group: ""
    resources: ["pods", "services"]
  - group: "apps"
    resources: ["deployments", "replicasets"]

- level: RequestResponse
  namespaces: ["production"]
  verbs: ["create", "update", "patch"]
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]

- level: Request
  users: ["system:serviceaccount:kube-system:default"]
  verbs: ["get", "list", "watch"]
  resources:
  - group: ""
    resources: ["secrets"]
```

## Best Practices

### 1. Security Context Hierarchy
```yaml
# Apply security at multiple levels
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  template:
    spec:
      # Pod-level security context
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: app
        image: nginx:1.21
        # Container-level security context (overrides pod-level)
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
            add:
            - NET_BIND_SERVICE
```

### 2. Least Privilege Principle
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: minimal-privileges
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 65534  # nobody user
    runAsGroup: 65534
    fsGroup: 65534
  containers:
  - name: app
    image: nginx:1.21
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "200m"
```

### 3. Defense in Depth
```yaml
# Multiple security layers
apiVersion: v1
kind: Pod
metadata:
  name: defense-in-depth
  annotations:
    # AppArmor profile
    container.apparmor.security.beta.kubernetes.io/app: localhost/k8s-nginx
spec:
  securityContext:
    # Pod security context
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    # Seccomp profile
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.21
    securityContext:
      # Container security context
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    # Resource limits
    resources:
      limits:
        memory: "128Mi"
        cpu: "200m"
    # Health checks
    livenessProbe:
      httpGet:
        path: /
        port: 8080
    readinessProbe:
      httpGet:
        path: /
        port: 8080
```

## Troubleshooting

### Common Security Issues

#### 1. Permission Denied Errors
```bash
# Check security context
kubectl describe pod pod-name | grep -A 10 "Security Context"

# Verify user/group IDs
kubectl exec -it pod-name -- id

# Check file permissions
kubectl exec -it pod-name -- ls -la /path/to/file
```

#### 2. Capability Issues
```bash
# Check required capabilities
kubectl describe pod pod-name | grep -A 5 "Capabilities"

# Test capability requirements
kubectl exec -it pod-name -- capsh --print
```

#### 3. Seccomp Profile Problems
```bash
# Check seccomp profile
kubectl describe pod pod-name | grep -A 3 "Seccomp"

# Verify profile exists
ls /var/lib/kubelet/seccomp/profiles/
```

### Security Validation Tools
```bash
# Kube-bench security benchmark
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

# Kube-hunter penetration testing
kubectl create job kube-hunter --image=aquasec/kube-hunter

# Polaris security validation
kubectl apply -f https://github.com/FairwindsOps/polaris/releases/latest/download/dashboard.yaml
```

## Compliance and Standards

### CIS Kubernetes Benchmark
```bash
# Run CIS benchmark
docker run --rm -v `pwd`:/host aquasec/kube-bench:latest run --targets node --version 1.6.0

# Check specific controls
kube-bench run --check 4.2.1,4.2.2,4.2.3
```

### NIST Guidelines
```yaml
# NIST 800-190 compliant pod
apiVersion: v1
kind: Pod
metadata:
  name: nist-compliant
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.21@sha256:abc123...  # Use digest for immutability
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "200m"
```

## Conclusion

Pod Security in Kubernetes requires a multi-layered approach combining Pod Security Standards, Security Contexts, admission controls, and runtime monitoring. Proper implementation ensures containers run with minimal privileges while maintaining functionality and protecting the underlying infrastructure from security threats.