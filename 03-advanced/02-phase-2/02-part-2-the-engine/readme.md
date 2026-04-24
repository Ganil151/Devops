# ⚙️ Part 2: The Engine (Delivery & Traffic)

> **"Kubernetes creates the Pods. GitOps ensures they exist. The Service Mesh ensures they can talk. You are the conductor of this orchestra."**

Welcome to **The Engine**. In Phase 1, you learned CI/CD pipelines. In Phase 2, we move to **Continuous Operations**.

## 🛣️ The Curriculum

### [01-GitOps-Fleet](./01-gitops-fleet/)
**The Objective**: Manage 100 clusters as easily as 1.
*   **Key Concepts**: 
    *   **App of Apps Pattern**: Using ArgoCD to bootstrap entire cluster stacks.
    *   **ApplicationSets**: Generating applications from Git folder structures.
    *   **Progressive Delivery**: Canary deployments with Argo Rollouts (Traffic shifting).

### [02-Service-Mesh](./02-service-mesh/)
**The Objective**: Decouple "Networking" from "Application Code".
*   **Key Concepts**:
    *   **mTLS Everywhere**: Zero-trust security without code changes.
    *   **Traffic Management**: Circuit breaking, retries, timeouts, and fault injection configuration in YAML.
    *   **Observability**: Golden metrics (Latency, Traffic, Errors) for free.

### [003-Advanced-Automation](./003-advanced-automation/)
**The Objective**: If you do it twice, automate it. If you need it done instantly, use Events.
*   **Key Concepts**:
    *   **Event-Driven Architecture**: Triggering Lambda/Functions from Kafka/SQS events.
    *   **Crossplane**: Managing Cloud Infrastructure using Kubernetes YAML (Control Plane).
    *   **Custom Operators**: Extending Kubernetes API to manage your own CRDs.

---

## 🚀 The Difference: Junior vs. Senior

| Feature | Junior Approach | Principal Approach |
|:---|:---|:---|
| **Deployment** | "I run `kubectl apply`." | "I merge a PR, ArgoCD syncs, and Rollouts manages a 5% canary step." |
| **Security** | "I trust the internal network." | "I enforce mTLS between all microservices via Istio." |
| **Scaling** | "I wrote a bash script." | "I wrote a Kubernetes Operator to manage the lifecycle." |

---

## 🛠️ The Toolkit

*   **ArgoCD & Rollouts**: The GitOps Standard.
*   **Istio / Linkerd**: Service Mesh leaders.
*   **Crossplane**: Infrastructure as Data.
*   **KEDA**: Event-driven autoscaling.

---
**Status**: ✅ Organized (2026-02-02)
