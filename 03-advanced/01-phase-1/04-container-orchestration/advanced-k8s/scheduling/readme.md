# Advanced Level: Scheduling

Kubernetes scheduling is the process of assigning Pods to Nodes. By default, the `kube-scheduler` filters and scores nodes to find the best fit, but you often need more control for high-availability, performance, or legal reasons.

## 🎯 Learning Objectives
- Understanding **Taints** and **Tolerations**.
- Using **Node Affinity** to guide selection.
- Using **Pod Affinity/Anti-Affinity** for co-location or spreading.

## 1. Taints and Tolerations
*Action: Repelling Pods from Nodes.*

### Taints (On Nodes)
Taints allow a node to repel a set of pods.
```bash
# Taint a node so only special pods can land there
kubectl taint nodes node1 gpu=true:NoSchedule
```
Effects:
- `NoSchedule`: Do not schedule new pods unless they tolerate.
- `PreferNoSchedule`: Try to avoid, but schedule if no other option.
- `NoExecute`: Evict existing pods if they don't tolerate.

### Tolerations (On Pods)
Tolerations allow (but do not require) pods to schedule onto nodes with matching taints.
```yaml
spec:
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

## 2. Node Affinity
*Action: Attracting Pods to Nodes.*

Similar to `nodeSelector` but more expressive.

```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
```

## 3. Pod Affinity & Anti-Affinity
*Action: Attracting/Repelling Pods relative to other Pods.*

### Anti-Affinity (Spreading)
Critical for High Availability. Don't put two replicas of the same app on the same node!
```yaml
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - web-store
        topologyKey: "kubernetes.io/hostname"
```

### Affinity (Co-location)
For performance, put a Cache pod on the same node as the Web pod.
```yaml
spec:
  affinity:
    podAffinity:
       ...
```

[Back to Advanced Index](../readme.md)
