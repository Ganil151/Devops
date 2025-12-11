# Kubernetes Architecture Directory Mind Map

```
Kubernetes/Architecture/
│
├── Control-Plane/
│   ├── 1-Cloud_Controller_Manager/     # Cloud provider integration
│   ├── 2-Kube_Api_Server/             # Central API gateway
│   ├── 3-ETCD/                        # Distributed key-value store
│   ├── 4-Kube-Scheduler/              # Pod scheduling decisions
│   └── 5-Kube_Controller_Manager/     # State reconciliation
│
├── Node-Components/
│   ├── kubelet/                       # Node agent
│   ├── nodes/                         # Worker node management
│   └── crictl/                        # Container runtime CLI
│
├── Workload-Resources/
│   ├── pods/                          # Basic execution units
│   ├── deployments/                   # Application deployment
│   ├── statefulsets/                  # Stateful applications
│   ├── daemonsets/                    # Node-wide services
│   ├── jobs/                          # Batch processing
│   └── cronjobs/                      # Scheduled tasks
│
├── Networking/
│   ├── services/                      # Service discovery
│   ├── ingress/                       # External access
│   └── network-policies/              # Network security
│
├── Storage/
│   ├── persistent-volumes/            # Durable storage
│   └── storage-class/                 # Dynamic provisioning
│
├── Configuration/
│   ├── configMaps/                    # Configuration data
│   └── secrets/                       # Sensitive data
│
├── Security/
│   ├── rbac/                          # Access control
│   ├── service-accounts/              # Pod identity
│   └── namespaces/                    # Resource isolation
│
├── Autoscaling/
│   ├── hpa/                           # Horizontal scaling
│   ├── vpa/                           # Vertical scaling
│   └── pdb/                           # Disruption budgets
│
├── Tools/
│   └── kubectl/                       # CLI interface
│
└── cluster/                           # Overall architecture
```

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

## Learning Path

1. **Foundation**: cluster → nodes → pods
2. **Workloads**: deployments → services → ingress
3. **Storage**: persistent-volumes → storage-class
4. **Configuration**: configMaps → secrets → namespaces
5. **Security**: rbac → service-accounts → network-policies
6. **Advanced**: statefulsets → jobs → autoscaling