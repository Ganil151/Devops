# Kubernetes Architecture Directory Mind Map
> **⚠️ Missing Image**: *DMM* ('../../../../../08-Resources/03-Images-Diagrams/Kubernetes/kube-folder-mindMap.png')
---

## Component Relationships

```
API Server ←→ ETCD (stores cluster state)
    ↓
Scheduler (watches unscheduled pods)
    ↓
Kubelet (receives pod assignments)
    ↓
Container Runtime (runs containers)

Services ←→ Pods (service discovery)
Ingress ←→ Services (external access)
PVC ←→ PV (storage binding)
ConfigMaps/Secrets ←→ Pods (configuration injection)
```
---


## Learning Path

1. **Foundation**: cluster → nodes → pods
2. **Workloads**: deployments → services → ingress
3. **Storage**: persistent-volumes → storage-class
4. **Configuration**: configMaps → secrets → namespaces
5. **Security**: rbac → service-accounts → network-policies
6. **Advanced**: statefulsets → jobs → autoscaling
---