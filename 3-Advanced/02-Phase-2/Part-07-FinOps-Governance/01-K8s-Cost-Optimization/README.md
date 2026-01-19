# 📉 FinOps: Kubernetes Resource Optimization

> **"Stopping the waste is the first step to cloud profitability. Rightsize your fleet automatically."**

## 📚 Overview

Kubernetes makes it easy to requested more resources than you actually need. This "Slack" in resource allocation is the leading cause of wasted cloud spend. This module focuses on using **VPA (Vertical Pod Autoscaler)** and **Goldilocks** to identify and eliminate wasteful resource requests while ensuring application stability.

## 🎯 Learning Objectives

- ✅ Implement **Vertical Pod Autoscaler (VPA)** in recommendation mode.
- ✅ Use **Goldilocks** to visualize resource "Right-Sizing" recommendations.
- ✅ Understand the trade-offs between **Limit Range** and **Quotas**.
- ✅ Build automated pipelines to update K8s manifests with cost-optimized values.

## 🗺️ Module Structure

1. **[🔴 01-VPA-Vertical-Pod-Autoscaler](./01-VPA-Vertical-Pod-Autoscaler/)**
   - Installing the VPA controller.
   - Analyzing `Recommended` vs. `Actual` usage.
2. **[🔴 02-Goldilocks-Rightsizing](./02-Goldilocks-Rightsizing/)**
   - Dashboarding recommendations for all namespaces.
   - Setting "Fair" vs. "Aggressive" optimization profiles.

---

## 🏗️ Visual: The Right-Sizing Workflow

```mermaid
graph LR
    A[Cluster Metrics] --> B[VPA Recommender]
    B --> C[Goldilocks Dashboard]
    C -->|Developer Review| D[Updated YAML Manifest]
    D --> E[GitOps Sync]
    E --> F[Reduced Cloud Bill 💰]
    
    style B fill:#34a853,color:#fff
    style C fill:#4285f4,color:#fff
    style F fill:#f1c40f,color:#000
```

---

## 🛠️ YAML: VPA in Recommendation Mode


```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: billing-service-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       billing-service
  updatePolicy:
    updateMode: "Off" # Recommendations only, no automatic restarts
```

## 📋 Professional Pattern: "Trust but Verify"
When starting with VPA, always use `updateMode: "Off"`. Let it collect 7+ days of metrics to account for traffic spikes (e.g., weekend surges). Only once the recommendations have stabilized should you consider moving to `"Auto"` mode for non-critical workloads.

---
**Next Step**: Start with [VPA Fundamentals](./01-VPA-Vertical-Pod-Autoscaler/) 🚀
