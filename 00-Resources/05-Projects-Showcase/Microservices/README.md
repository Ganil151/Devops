# Advanced Microservices & Orchestration

This directory contains production-ready microservice implementations designed for Kubernetes environments, specifically optimized for AWS EKS.

---

## 🏛️ Project Architecture

### 1. Service Communication
- **REST & gRPC**: High-performance communication patterns between services.
- **Service Mesh (Istio)**: Mutual TLS, Traffic Splitting (Canary), and Circuit Breaking.

### 2. Infrastructure
- **Manifests**: Standard YAML declarations for Deployments, Services, and ConfigMaps.
- **Helm Charts**: Templatized deployments for scaling across environments.

---

## 🔍 Observability Stack
- **Prometheus**: Real-time metrics collection.
- **Grafana**: Visualizing service health and performance.
- **Jaeger/X-Ray**: Distributed tracing to follow requests across service boundaries.

---

## 🚀 Deployment Steps
1. **Cluster Creation**: Use `eksctl` or Terraform to provision your EKS cluster.
2. **Registry**: Push service images to Amazon ECR.
3. **Deploy**: Apply the Helm charts or K8s manifests:
   ```bash
   kubectl apply -f ./manifests/
   # OR
   helm install my-app ./charts/
   ```

---
**Reference**: For a deep dive into the underlying technology, see the [Advanced K8s Module](../../README.md).