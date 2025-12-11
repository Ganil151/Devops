# Kubernetes Admission Controllers

## Overview

**Kubernetes Admission Controllers** are plugins that govern and enforce how the cluster is used. They intercept requests to the Kubernetes API server after authentication and authorization but before object persistence. Admission controllers can validate, mutate, or reject requests.

## Admission Control Flow

```
┌─────────────────────────────────────────────────────────────┐
│                Admission Control Pipeline                    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │   Client    │  │ API Server  │  │   Admission     │     │
│  │  Request    │  │ Auth/Authz  │  │  Controllers    │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │  Mutating   │  │ Validating  │  │     etcd        │     │
│  │ Admission   │  │ Admission   │  │   Persistence   │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Built-in Admission Controllers

### Essential Controllers
```bash
# View enabled admission controllers
kubectl get --raw /api/v1 | jq '.serverAddressByClientCIDRs'

# Common admission controllers
--enable-admission-plugins=NodeRestriction,ResourceQuota,PodSecurityPolicy,DefaultStorageClass,MutatingAdmissionWebhook,ValidatingAdmissionWebhook
```

### NodeRestriction
```yaml
# Restricts kubelet permissions to only modify own node and pods
# Automatically enabled in most clusters
# No configuration required - built into API server
```

### ResourceQuota
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: production
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "10"
    persistentvolumeclaims: "4"
    services: "5"
    secrets: "10"
    configmaps: "10"
```

### LimitRanger
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-range
  namespace: production
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "2"
      memory: "2Gi"
    min:
      cpu: "50m"
      memory: "64Mi"
    type: Container
  - max:
      storage: "10Gi"
    min:
      storage: "1Gi"
    type: PersistentVolumeClaim
```

### DefaultStorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  fsType: ext4
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

## Mutating Admission Webhooks

### Webhook Configuration
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingAdmissionWebhook
metadata:
  name: pod-mutator
webhooks:
- name: pod-mutator.example.com
  clientConfig:
    service:
      name: pod-mutator-service
      namespace: webhook-system
      path: "/mutate"
    caBundle: LS0tLS1CRUdJTi...  # Base64 encoded CA certificate
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  admissionReviewVersions: ["v1", "v1beta1"]
  sideEffects: None
  failurePolicy: Fail
```

### Mutating Webhook Server
```go
// Example mutating webhook server (Go)
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    
    admissionv1 "k8s.io/api/admission/v1"
    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/runtime"
)

func mutatePod(w http.ResponseWriter, r *http.Request) {
    var body []byte
    if r.Body != nil {
        if data, err := ioutil.ReadAll(r.Body); err == nil {
            body = data
        }
    }

    var admissionResponse *admissionv1.AdmissionResponse
    ar := admissionv1.AdmissionReview{}
    
    if err := json.Unmarshal(body, &ar); err != nil {
        admissionResponse = &admissionv1.AdmissionResponse{
            Result: &metav1.Status{
                Message: err.Error(),
            },
        }
    } else {
        admissionResponse = mutate(&ar)
    }

    admissionReview := admissionv1.AdmissionReview{}
    if admissionResponse != nil {
        admissionReview.Response = admissionResponse
        if ar.Request != nil {
            admissionReview.Response.UID = ar.Request.UID
        }
    }

    respBytes, _ := json.Marshal(admissionReview)
    w.Header().Set("Content-Type", "application/json")
    w.Write(respBytes)
}

func mutate(ar *admissionv1.AdmissionReview) *admissionv1.AdmissionResponse {
    req := ar.Request
    var pod corev1.Pod
    
    if err := json.Unmarshal(req.Object.Raw, &pod); err != nil {
        return &admissionv1.AdmissionResponse{
            Result: &metav1.Status{
                Message: err.Error(),
            },
        }
    }

    // Add security context if missing
    patches := []map[string]interface{}{}
    
    if pod.Spec.SecurityContext == nil {
        patch := map[string]interface{}{
            "op":    "add",
            "path":  "/spec/securityContext",
            "value": map[string]interface{}{
                "runAsNonRoot": true,
                "runAsUser":    1000,
            },
        }
        patches = append(patches, patch)
    }

    // Add resource limits if missing
    for i, container := range pod.Spec.Containers {
        if container.Resources.Limits == nil {
            patch := map[string]interface{}{
                "op":   "add",
                "path": fmt.Sprintf("/spec/containers/%d/resources/limits", i),
                "value": map[string]interface{}{
                    "cpu":    "500m",
                    "memory": "512Mi",
                },
            }
            patches = append(patches, patch)
        }
    }

    patchBytes, _ := json.Marshal(patches)
    
    return &admissionv1.AdmissionResponse{
        UID:     req.UID,
        Allowed: true,
        Patch:   patchBytes,
        PatchType: func() *admissionv1.PatchType {
            pt := admissionv1.PatchTypeJSONPatch
            return &pt
        }(),
    }
}
```

### Sidecar Injection Example
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingAdmissionWebhook
metadata:
  name: sidecar-injector
webhooks:
- name: sidecar-injector.example.com
  clientConfig:
    service:
      name: sidecar-injector
      namespace: istio-system
      path: "/inject"
  rules:
  - operations: ["CREATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  namespaceSelector:
    matchLabels:
      istio-injection: enabled
  admissionReviewVersions: ["v1"]
```

## Validating Admission Webhooks

### Webhook Configuration
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionWebhook
metadata:
  name: pod-validator
webhooks:
- name: pod-validator.example.com
  clientConfig:
    service:
      name: pod-validator-service
      namespace: webhook-system
      path: "/validate"
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  admissionReviewVersions: ["v1"]
  sideEffects: None
  failurePolicy: Fail
```

### Validation Logic Example
```go
func validatePod(ar *admissionv1.AdmissionReview) *admissionv1.AdmissionResponse {
    req := ar.Request
    var pod corev1.Pod
    
    if err := json.Unmarshal(req.Object.Raw, &pod); err != nil {
        return &admissionv1.AdmissionResponse{
            Result: &metav1.Status{
                Message: err.Error(),
            },
        }
    }

    allowed := true
    message := ""

    // Validate security context
    if pod.Spec.SecurityContext == nil || !*pod.Spec.SecurityContext.RunAsNonRoot {
        allowed = false
        message = "Pod must run as non-root user"
    }

    // Validate image registry
    for _, container := range pod.Spec.Containers {
        if !strings.HasPrefix(container.Image, "registry.company.com/") {
            allowed = false
            message = "Images must come from approved registry"
        }
    }

    // Validate resource limits
    for _, container := range pod.Spec.Containers {
        if container.Resources.Limits == nil {
            allowed = false
            message = "All containers must have resource limits"
        }
    }

    return &admissionv1.AdmissionResponse{
        UID:     req.UID,
        Allowed: allowed,
        Result: &metav1.Status{
            Message: message,
        },
    }
}
```

## OPA Gatekeeper

### Installation
```bash
# Install Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
```

### Constraint Templates
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels
        
        violation[{"msg": msg}] {
          required := input.parameters.labels
          provided := input.review.object.metadata.labels
          missing := required[_]
          not provided[missing]
          msg := sprintf("Missing required label: %v", [missing])
        }
```

### Constraints
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: must-have-owner
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
    namespaces: ["production"]
  parameters:
    labels: ["owner", "environment", "version"]
```

### Advanced Gatekeeper Policies
```yaml
# Container security policy
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8scontainersecurity
spec:
  crd:
    spec:
      names:
        kind: K8sContainerSecurity
      validation:
        openAPIV3Schema:
          type: object
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8scontainersecurity
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.runAsNonRoot
          msg := "Container must run as non-root user"
        }
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          container.securityContext.privileged
          msg := "Privileged containers are not allowed"
        }
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.resources.limits
          msg := "Container must have resource limits"
        }
---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sContainerSecurity
metadata:
  name: container-security-policy
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
      - apiGroups: ["apps"]
        kinds: ["Deployment", "ReplicaSet", "DaemonSet", "StatefulSet"]
```

## Kyverno Policy Engine

### Installation
```bash
# Install Kyverno
kubectl create -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml
```

### Validation Policies
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-pod-resources
spec:
  validationFailureAction: enforce
  background: true
  rules:
  - name: validate-resources
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Resource requests and limits are required"
      pattern:
        spec:
          containers:
          - name: "*"
            resources:
              requests:
                memory: "?*"
                cpu: "?*"
              limits:
                memory: "?*"
                cpu: "?*"
```

### Mutation Policies
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-security-context
spec:
  rules:
  - name: add-security-context
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        spec:
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
          containers:
          - (name): "*"
            securityContext:
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: true
              capabilities:
                drop:
                - ALL
```

### Generation Policies
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-network-policy
spec:
  rules:
  - name: generate-default-deny
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      kind: NetworkPolicy
      name: default-deny
      namespace: "{{request.object.metadata.name}}"
      data:
        spec:
          podSelector: {}
          policyTypes:
          - Ingress
          - Egress
```

## Custom Admission Controllers

### Webhook Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admission-webhook
  namespace: webhook-system
spec:
  replicas: 2
  selector:
    matchLabels:
      app: admission-webhook
  template:
    metadata:
      labels:
        app: admission-webhook
    spec:
      containers:
      - name: webhook
        image: admission-webhook:latest
        ports:
        - containerPort: 8443
        env:
        - name: TLS_CERT_FILE
          value: /etc/certs/tls.crt
        - name: TLS_PRIVATE_KEY_FILE
          value: /etc/certs/tls.key
        volumeMounts:
        - name: certs
          mountPath: /etc/certs
          readOnly: true
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
      volumes:
      - name: certs
        secret:
          secretName: webhook-certs
---
apiVersion: v1
kind: Service
metadata:
  name: admission-webhook-service
  namespace: webhook-system
spec:
  selector:
    app: admission-webhook
  ports:
  - port: 443
    targetPort: 8443
    protocol: TCP
```

### Certificate Management
```yaml
# Certificate for webhook
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: webhook-cert
  namespace: webhook-system
spec:
  secretName: webhook-certs
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
  dnsNames:
  - admission-webhook-service.webhook-system.svc
  - admission-webhook-service.webhook-system.svc.cluster.local
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
```

## Monitoring and Debugging

### Admission Controller Metrics
```yaml
# Prometheus monitoring
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: admission-controller-metrics
spec:
  selector:
    matchLabels:
      app: admission-webhook
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

### Debugging Admission Issues
```bash
# Check admission controller logs
kubectl logs -n kube-system kube-apiserver-master-node

# View webhook configurations
kubectl get mutatingadmissionwebhooks
kubectl get validatingadmissionwebhooks

# Test webhook connectivity
kubectl get --raw /api/v1/namespaces/default/pods

# Check webhook service
kubectl get svc -n webhook-system admission-webhook-service

# Verify certificates
kubectl get secret -n webhook-system webhook-certs -o yaml
```

### Admission Review Logging
```go
// Log admission requests for debugging
func logAdmissionRequest(ar *admissionv1.AdmissionReview) {
    log.Printf("Admission Request: Kind=%s, Namespace=%s, Name=%s, Operation=%s",
        ar.Request.Kind.Kind,
        ar.Request.Namespace,
        ar.Request.Name,
        ar.Request.Operation)
}
```

## Best Practices

### 1. Webhook Reliability
```yaml
# High availability webhook deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admission-webhook
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: admission-webhook
              topologyKey: kubernetes.io/hostname
```

### 2. Failure Policies
```yaml
# Graceful failure handling
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionWebhook
metadata:
  name: safe-validator
webhooks:
- name: validator.example.com
  failurePolicy: Ignore  # Allow requests if webhook fails
  timeoutSeconds: 10     # Reasonable timeout
  sideEffects: None      # No side effects
```

### 3. Namespace Exemptions
```yaml
# Exempt system namespaces
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionWebhook
metadata:
  name: production-validator
webhooks:
- name: validator.example.com
  namespaceSelector:
    matchExpressions:
    - key: name
      operator: NotIn
      values: ["kube-system", "kube-public", "kube-node-lease"]
```

### 4. Testing and Validation
```bash
# Test admission policies
kubectl apply --dry-run=server -f test-pod.yaml

# Validate webhook configuration
kubectl get validatingadmissionwebhooks webhook-name -o yaml

# Test with different operations
kubectl create -f test-resource.yaml
kubectl patch resource test-resource -p '{"metadata":{"labels":{"test":"value"}}}'
```

## Security Considerations

### 1. Webhook Security
```yaml
# Secure webhook configuration
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingAdmissionWebhook
metadata:
  name: secure-webhook
webhooks:
- name: webhook.example.com
  clientConfig:
    service:
      name: webhook-service
      namespace: webhook-system
      path: "/mutate"
    caBundle: LS0tLS1CRUdJTi...  # Always use CA bundle
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  failurePolicy: Fail  # Fail closed for security
  sideEffects: None
  timeoutSeconds: 30
```

### 2. RBAC for Webhooks
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: webhook-reader
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list"]
- apiGroups: ["admissionregistration.k8s.io"]
  resources: ["mutatingadmissionwebhooks", "validatingadmissionwebhooks"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: webhook-reader-binding
subjects:
- kind: ServiceAccount
  name: webhook-service-account
  namespace: webhook-system
roleRef:
  kind: ClusterRole
  name: webhook-reader
  apiGroup: rbac.authorization.k8s.io
```

## Troubleshooting Guide

### Common Issues

#### 1. Webhook Timeout
```bash
# Check webhook response time
kubectl get events --field-selector reason=FailedAdmissionWebhook

# Increase timeout
kubectl patch validatingadmissionwebhook webhook-name -p '{"webhooks":[{"name":"webhook.example.com","timeoutSeconds":30}]}'
```

#### 2. Certificate Issues
```bash
# Verify certificate validity
openssl x509 -in webhook.crt -text -noout

# Check certificate in secret
kubectl get secret webhook-certs -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout
```

#### 3. Policy Conflicts
```bash
# Check for conflicting policies
kubectl get constraints --all-namespaces
kubectl describe constraint constraint-name

# Validate policy logic
opa test policy.rego policy_test.rego
```

## Conclusion

Admission Controllers provide powerful mechanisms for enforcing security policies, compliance requirements, and operational standards in Kubernetes clusters. Proper implementation requires careful consideration of reliability, security, and performance impacts. Regular testing and monitoring ensure admission controllers continue to function correctly as cluster requirements evolve.