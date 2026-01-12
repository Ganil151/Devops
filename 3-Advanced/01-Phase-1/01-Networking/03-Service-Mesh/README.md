# Service Mesh Technologies for DevOps

Advanced service mesh implementations for microservices architectures. This section covers Istio, Linkerd, Consul Connect, and other service mesh technologies essential for modern cloud-native applications.

## 🎯 Learning Objectives

- Master service mesh architecture and concepts
- Implement Istio for traffic management and security
- Deploy Linkerd for lightweight service mesh
- Configure Consul Connect for service discovery and security
- Understand multi-cluster service mesh deployments
- Implement observability and monitoring for service mesh

## 🕸️ Service Mesh Fundamentals

### What is a Service Mesh?

A service mesh is a dedicated infrastructure layer that handles service-to-service communication in microservices architectures.

**Key Components:**
```
┌─────────────────────────────────────────┐
│            Control Plane                │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │   Pilot     │  │    Citadel      │   │
│  │ (Traffic    │  │  (Security)     │   │
│  │ Management) │  │                 │   │
│  └─────────────┘  └─────────────────┘   │
│                                         │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │   Galley    │  │    Telemetry    │   │
│  │(Configuration)│ │   (Observability)│   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
                    │
┌─────────────────────────────────────────┐
│             Data Plane                  │
│                                         │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐     │
│ │Service A│ │Service B│ │Service C│     │
│ │ ┌─────┐ │ │ ┌─────┐ │ │ ┌─────┐ │     │
│ │ │ App │ │ │ │ App │ │ │ │ App │ │     │
│ │ └─────┘ │ │ └─────┘ │ │ └─────┘ │     │
│ │ ┌─────┐ │ │ ┌─────┐ │ │ ┌─────┐ │     │
│ │ │Proxy│ │ │ │Proxy│ │ │ │Proxy│ │     │
│ │ └─────┘ │ │ └─────┘ │ │ └─────┘ │     │
│ └─────────┘ └─────────┘ └─────────┘     │
└─────────────────────────────────────────┘
```

### Service Mesh Benefits

**Traffic Management:**
- Load balancing and routing
- Circuit breaking and retries
- Canary deployments and A/B testing
- Traffic splitting and mirroring

**Security:**
- Mutual TLS (mTLS) encryption
- Authentication and authorization
- Security policy enforcement
- Certificate management

**Observability:**
- Distributed tracing
- Metrics collection
- Access logging
- Service topology visualization

## 🌊 Istio Service Mesh

### Istio Architecture

**Core Components:**
- **Envoy Proxy**: Data plane proxy
- **Pilot**: Traffic management
- **Citadel**: Security and certificate management
- **Galley**: Configuration validation and distribution
- **Mixer**: Telemetry and policy (deprecated in newer versions)

### Istio Installation

**Installation with istioctl:**
```bash
# Download Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# Install Istio
istioctl install --set values.defaultRevision=default

# Verify installation
kubectl get pods -n istio-system

# Enable sidecar injection for namespace
kubectl label namespace default istio-injection=enabled

# Verify sidecar injection
kubectl get namespace -L istio-injection
```

**Installation with Helm:**
```bash
# Add Istio Helm repository
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# Install Istio base
helm install istio-base istio/base -n istio-system --create-namespace

# Install Istio discovery
helm install istiod istio/istiod -n istio-system --wait

# Install Istio ingress gateway
helm install istio-ingress istio/gateway -n istio-system
```

### Traffic Management with Istio

**Virtual Service Configuration:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
  - bookinfo.example.com
  gateways:
  - bookinfo-gateway
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - match:
    - uri:
        prefix: "/api/v1"
    route:
    - destination:
        host: reviews
        subset: v1
      weight: 90
    - destination:
        host: reviews
        subset: v3
      weight: 10
  - route:
    - destination:
        host: reviews
        subset: v1
```

**Destination Rule Configuration:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews-destination
spec:
  host: reviews
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 10
    circuitBreaker:
      consecutiveGatewayErrors: 5
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
    outlierDetection:
      splitExternalLocalOriginErrors: true
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
    trafficPolicy:
      connectionPool:
        tcp:
          maxConnections: 50
  - name: v3
    labels:
      version: v3
```

**Gateway Configuration:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: bookinfo-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: bookinfo-secret
    hosts:
    - bookinfo.example.com
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - bookinfo.example.com
    tls:
      httpsRedirect: true
```

### Istio Security Features

**Authentication Policy:**
```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: reviews-auth
spec:
  selector:
    matchLabels:
      app: reviews
  mtls:
    mode: STRICT
  portLevelMtls:
    9080:
      mode: DISABLE
```

**Authorization Policy:**
```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: reviews-policy
spec:
  selector:
    matchLabels:
      app: reviews
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/productpage"]
  - to:
    - operation:
        methods: ["GET"]
  - when:
    - key: request.headers[version]
      values: ["v1", "v2"]
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: deny-all
spec:
  {}  # Empty rule denies all requests
```

**Request Authentication (JWT):**
```yaml
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: jwt-auth
spec:
  selector:
    matchLabels:
      app: reviews
  jwtRules:
  - issuer: "https://auth.example.com"
    jwksUri: "https://auth.example.com/.well-known/jwks.json"
    audiences:
    - "reviews-service"
    forwardOriginalToken: true
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-jwt
spec:
  selector:
    matchLabels:
      app: reviews
  rules:
  - from:
    - source:
        requestPrincipals: ["https://auth.example.com/user@example.com"]
```

### Canary Deployments with Istio

**Canary Deployment Strategy:**
```yaml
# Deploy canary version
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reviews-v3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reviews
      version: v3
  template:
    metadata:
      labels:
        app: reviews
        version: v3
    spec:
      containers:
      - name: reviews
        image: reviews:v3
        ports:
        - containerPort: 9080
---
# Traffic splitting configuration
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews-canary
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: reviews
        subset: v3
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 95
    - destination:
        host: reviews
        subset: v3
      weight: 5
```

## 🔗 Linkerd Service Mesh

### Linkerd Architecture

Linkerd is a lightweight, security-first service mesh designed for simplicity and performance.

**Key Components:**
- **Linkerd Proxy**: Ultra-light Rust-based proxy
- **Control Plane**: Manages configuration and certificates
- **CLI**: Command-line interface for management
- **Web UI**: Graphical interface for monitoring

### Linkerd Installation

**Installation Steps:**
```bash
# Download and install Linkerd CLI
curl -sL https://run.linkerd.io/install | sh
export PATH=$PATH:$HOME/.linkerd2/bin

# Validate cluster
linkerd check --pre

# Install Linkerd control plane
linkerd install | kubectl apply -f -

# Verify installation
linkerd check

# Install Linkerd viz extension
linkerd viz install | kubectl apply -f -

# Access dashboard
linkerd viz dashboard
```

### Linkerd Traffic Management

**Service Profile for Traffic Splitting:**
```yaml
apiVersion: linkerd.io/v1alpha2
kind: ServiceProfile
metadata:
  name: webapp
  namespace: default
spec:
  routes:
  - name: api_routes
    condition:
      method: GET
      pathRegex: "/api/.*"
    responseClasses:
    - condition:
        status:
          min: 500
          max: 599
      isFailure: true
  retryBudget:
    retryRatio: 0.2
    minRetriesPerSecond: 10
    ttl: 10s
---
apiVersion: linkerd.io/v1alpha2
kind: TrafficSplit
metadata:
  name: webapp-split
spec:
  service: webapp
  backends:
  - service: webapp-v1
    weight: 90
  - service: webapp-v2
    weight: 10
```

**Linkerd Ingress Configuration:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/service-upstream: "true"
    nginx.ingress.kubernetes.io/upstream-vhost: webapp.default.svc.cluster.local
spec:
  ingressClassName: nginx
  rules:
  - host: webapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp
            port:
              number: 80
```

### Linkerd Security

**Automatic mTLS:**
```bash
# Linkerd automatically provides mTLS between meshed services
# Check mTLS status
linkerd viz edges

# View certificates
linkerd viz tap deployment/webapp --to deployment/api

# Policy configuration (Linkerd 2.12+)
kubectl apply -f - <<EOF
apiVersion: policy.linkerd.io/v1beta1
kind: Server
metadata:
  name: webapp-server
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: webapp
  port: 8080
  proxyProtocol: "HTTP/2"
---
apiVersion: policy.linkerd.io/v1beta1
kind: ServerAuthorization
metadata:
  name: webapp-auth
  namespace: default
spec:
  server:
    name: webapp-server
  client:
    meshTLS:
      serviceAccounts:
      - name: frontend
        namespace: default
EOF
```

## 🔌 Consul Connect Service Mesh

### Consul Connect Architecture

Consul Connect provides service mesh capabilities built on HashiCorp Consul.

**Key Features:**
- Service discovery and configuration
- Automatic mTLS encryption
- Intention-based access control
- Multi-datacenter support

### Consul Connect Setup

**Consul Installation with Connect:**
```bash
# Install Consul with Helm
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Install Consul with Connect enabled
helm install consul hashicorp/consul --set global.name=consul --set connectInject.enabled=true --set client.enabled=true --set client.grpc=true
```

**Consul Configuration:**
```hcl
# consul.hcl
datacenter = "dc1"
data_dir = "/opt/consul/data"
log_level = "INFO"
server = true
bootstrap_expect = 3
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
retry_join = ["consul-server-0", "consul-server-1", "consul-server-2"]

connect {
  enabled = true
}

ports {
  grpc = 8502
}

ui_config {
  enabled = true
}
```

### Service Registration and Connect

**Service Registration:**
```json
{
  "service": {
    "name": "web",
    "port": 8080,
    "connect": {
      "sidecar_service": {
        "proxy": {
          "upstreams": [
            {
              "destination_name": "api",
              "local_bind_port": 9191
            }
          ]
        }
      }
    },
    "check": {
      "http": "http://localhost:8080/health",
      "interval": "10s"
    }
  }
}
```

**Kubernetes Service Mesh with Consul:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
      annotations:
        consul.hashicorp.com/connect-inject: "true"
        consul.hashicorp.com/connect-service-upstreams: "api:9191"
    spec:
      containers:
      - name: web
        image: web:latest
        ports:
        - containerPort: 8080
        env:
        - name: API_URL
          value: "http://localhost:9191"
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - port: 8080
    targetPort: 8080
```

### Consul Connect Intentions

**Service Intentions (Access Control):**
```bash
# Allow web service to connect to api service
consul intention create web api

# Deny all other connections to api
consul intention create -deny "*" api

# Create intention with specific permissions
consul config write - <<EOF
Kind = "service-intentions"
Name = "api"
Sources = [
  {
    Name = "web"
    Action = "allow"
  },
  {
    Name = "admin"
    Action = "allow"
    Permissions = [
      {
        HTTP = {
          PathPrefix = "/admin"
          Methods = ["GET", "POST"]
        }
        Action = "allow"
      }
    ]
  },
  {
    Name = "*"
    Action = "deny"
  }
]
EOF
```

## 🌐 Multi-Cluster Service Mesh

### Istio Multi-Cluster Setup

**Primary Cluster Configuration:**
```bash
# Set cluster context
export CTX_CLUSTER1=cluster1
export CTX_CLUSTER2=cluster2

# Install Istio on primary cluster
kubectl --context="${CTX_CLUSTER1}" create namespace istio-system
kubectl --context="${CTX_CLUSTER1}" create secret generic cacerts -n istio-system \
  --from-file=root-cert.pem \
  --from-file=cert-chain.pem \
  --from-file=ca-cert.pem \
  --from-file=ca-key.pem

istioctl install --context="${CTX_CLUSTER1}" --set values.pilot.env.EXTERNAL_ISTIOD=true

# Create eastwest gateway
kubectl --context="${CTX_CLUSTER1}" apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: eastwest
spec:
  revision: ""
  components:
    ingressGateways:
      - name: istio-eastwestgateway
        label:
          istio: eastwestgateway
          app: istio-eastwestgateway
        enabled: true
        k8s:
          service:
            type: LoadBalancer
            ports:
              - port: 15021
                targetPort: 15021
                name: status-port
              - port: 15012
                targetPort: 15012
                name: tls
              - port: 15017
                targetPort: 15017
                name: tls-istiod
EOF
```

**Cross-Cluster Service Discovery:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: cross-network-gateway
  namespace: istio-system
spec:
  selector:
    istio: eastwestgateway
  servers:
  - port:
      number: 15443
      name: tls
      protocol: TLS
    tls:
      mode: ISTIO_MUTUAL
    hosts:
    - "*.local"
---
apiVersion: v1
kind: Service
metadata:
  name: helloworld
  labels:
    app: helloworld
    service: helloworld
spec:
  ports:
  - port: 5000
    name: http
  selector:
    app: helloworld
---
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: helloworld-remote
spec:
  hosts:
  - helloworld.sample.svc.cluster.local
  location: MESH_EXTERNAL
  ports:
  - number: 5000
    name: http
    protocol: HTTP
  resolution: DNS
  addresses:
  - 240.0.0.1
  endpoints:
  - address: helloworld.sample.svc.cluster.local
    network: network2
    ports:
      http: 15443
```

### Linkerd Multi-Cluster

**Multi-Cluster Link Setup:**
```bash
# Install Linkerd multicluster extension
linkerd --context=cluster1 multicluster install | kubectl --context=cluster1 apply -f -
linkerd --context=cluster2 multicluster install | kubectl --context=cluster2 apply -f -

# Create link between clusters
linkerd --context=cluster1 multicluster link --cluster-name cluster1 | kubectl --context=cluster2 apply -f -
linkerd --context=cluster2 multicluster link --cluster-name cluster2 | kubectl --context=cluster1 apply -f -

# Verify link
linkerd --context=cluster1 multicluster gateways
linkerd --context=cluster2 multicluster gateways

# Mirror service across clusters
kubectl --context=cluster1 label service/webapp mirror.linkerd.io/exported=true
kubectl --context=cluster2 get service webapp-cluster1
```

## 📊 Service Mesh Observability

### Distributed Tracing

**Jaeger Integration with Istio:**
```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: control-plane
spec:
  values:
    pilot:
      traceSampling: 100.0
    global:
      tracer:
        zipkin:
          address: jaeger-collector.istio-system:9411
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
  namespace: istio-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:1.35
        env:
        - name: COLLECTOR_ZIPKIN_HOST_PORT
          value: ":9411"
        ports:
        - containerPort: 9411
        - containerPort: 16686
```

**Custom Tracing Headers:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: custom-headers
spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: SIDECAR_INBOUND
      listener:
        filterChain:
          filter:
            name: "envoy.filters.network.http_connection_manager"
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.wasm
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
          config:
            configuration:
              "@type": type.googleapis.com/google.protobuf.StringValue
              value: |
                {
                  "headers": {
                    "x-trace-id": "{{.trace_id}}",
                    "x-span-id": "{{.span_id}}"
                  }
                }
```

### Metrics and Monitoring

**Prometheus Configuration for Service Mesh:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    
    scrape_configs:
    - job_name: 'istio-mesh'
      kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names:
          - istio-system
      relabel_configs:
      - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: istio-telemetry;prometheus
    
    - job_name: 'envoy-stats'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_container_port_name]
        action: keep
        regex: '.*-envoy-prom'
    
    - job_name: 'linkerd-controller'
      kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
          - linkerd
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_linkerd_io_control_plane_component]
        action: keep
        regex: .+
    
    - job_name: 'linkerd-proxy'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_container_name]
        action: keep
        regex: ^linkerd-proxy$
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_linkerd_io_proxy_admin_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
```

**Grafana Dashboard for Service Mesh:**
```json
{
  "dashboard": {
    "title": "Service Mesh Overview",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(istio_requests_total[5m])) by (source_app, destination_service_name)",
            "legendFormat": "{{source_app}} -> {{destination_service_name}}"
          }
        ]
      },
      {
        "title": "Success Rate",
        "type": "singlestat",
        "targets": [
          {
            "expr": "sum(rate(istio_requests_total{response_code!~\"5.*\"}[5m])) / sum(rate(istio_requests_total[5m]))",
            "legendFormat": "Success Rate"
          }
        ]
      },
      {
        "title": "P99 Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.99, sum(rate(istio_request_duration_milliseconds_bucket[5m])) by (le, destination_service_name))",
            "legendFormat": "{{destination_service_name}} P99"
          }
        ]
      }
    ]
  }
}
```

## 🧪 Advanced Service Mesh Labs

### Lab 1: Istio Canary Deployment

**Objective:** Implement automated canary deployment with Istio

**Setup:**
```bash
# Deploy application versions
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
      version: v1
  template:
    metadata:
      labels:
        app: webapp
        version: v1
    spec:
      containers:
      - name: webapp
        image: webapp:v1
        ports:
        - containerPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
      version: v2
  template:
    metadata:
      labels:
        app: webapp
        version: v2
    spec:
      containers:
      - name: webapp
        image: webapp:v2
        ports:
        - containerPort: 8080
EOF
```

**Automated Canary Script:**
```bash
#!/bin/bash
# canary-deployment.sh

NAMESPACE="default"
SERVICE="webapp"
NEW_VERSION="v2"
OLD_VERSION="v1"

# Function to update traffic split
update_traffic_split() {
    local new_weight=$1
    local old_weight=$((100 - new_weight))
    
    kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${SERVICE}-canary
  namespace: ${NAMESPACE}
spec:
  hosts:
  - ${SERVICE}
  http:
  - route:
    - destination:
        host: ${SERVICE}
        subset: ${OLD_VERSION}
      weight: ${old_weight}
    - destination:
        host: ${SERVICE}
        subset: ${NEW_VERSION}
      weight: ${new_weight}
EOF
}

# Function to check success rate
check_success_rate() {
    local threshold=0.95
    local query="sum(rate(istio_requests_total{destination_service_name=\"${SERVICE}\",response_code!~\"5.*\"}[2m])) / sum(rate(istio_requests_total{destination_service_name=\"${SERVICE}\"}[2m]))"
    
    local success_rate=$(curl -s "http://prometheus:9090/api/v1/query?query=${query}" | jq -r '.data.result[0].value[1]')
    
    if (( $(echo "$success_rate > $threshold" | bc -l) )); then
        return 0
    else
        return 1
    fi
}

# Canary deployment stages
stages=(5 10 25 50 75 100)

for stage in "${stages[@]}"; do
    echo "Deploying canary at ${stage}% traffic"
    update_traffic_split $stage
    
    # Wait for metrics to stabilize
    sleep 60
    
    # Check success rate
    if check_success_rate; then
        echo "Stage ${stage}% successful, proceeding..."
    else
        echo "Stage ${stage}% failed, rolling back..."
        update_traffic_split 0
        exit 1
    fi
done

echo "Canary deployment completed successfully!"
```

### Lab 2: Multi-Cluster Service Mesh

**Objective:** Set up cross-cluster service communication

**Primary Cluster Setup:**
```bash
# Install Istio with multi-cluster configuration
istioctl install --set values.pilot.env.EXTERNAL_ISTIOD=true --set values.global.meshID=mesh1 --set values.global.multiCluster.clusterName=cluster1 --set values.global.network=network1

# Create cross-network gateway
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: cross-network-gateway
  namespace: istio-system
spec:
  selector:
    istio: eastwestgateway
  servers:
  - port:
      number: 15443
      name: tls
      protocol: TLS
    tls:
      mode: ISTIO_MUTUAL
    hosts:
    - "*.local"
EOF
```

**Service Discovery Across Clusters:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: remote-service
spec:
  hosts:
  - api.production.svc.cluster.local
  location: MESH_EXTERNAL
  ports:
  - number: 8080
    name: http
    protocol: HTTP
  resolution: DNS
  addresses:
  - 240.0.0.2
  endpoints:
  - address: api.production.svc.cluster.local
    network: network2
    ports:
      http: 15443
```

## ✅ Advanced Assessment

### Service Mesh Architecture Design

**Requirements:**
- [ ] Design multi-cluster service mesh architecture
- [ ] Implement progressive delivery strategies
- [ ] Configure comprehensive security policies
- [ ] Set up observability and monitoring
- [ ] Plan disaster recovery procedures

**Evaluation Criteria:**
- Traffic management complexity
- Security policy effectiveness
- Observability completeness
- Performance optimization
- Operational procedures

## 🔗 Next Steps

- **[Performance Optimization](../Performance-Optimization/)** - Advanced performance tuning
- **[Cloud Networking](../Cloud-Networking/)** - Multi-cloud service mesh
- **[Network Automation](../Network-Automation/)** - Service mesh automation

---

*Service mesh technologies are essential for managing complex microservices architectures. Master these concepts to build resilient, secure, and observable distributed systems.*