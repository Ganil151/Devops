# StatefulSet Architecture and Concepts

This document provides visual representations of StatefulSet architecture, behavior, and key concepts using Mermaid diagrams.

---

## 1. StatefulSet Architecture Overview

```mermaid
graph TB
    subgraph "StatefulSet Architecture"
        SS[StatefulSet Controller]
        HS[Headless Service<br/>clusterIP: None]
        RS[Regular Service<br/>Load Balancer]
        
        subgraph "Pods with Stable Identity"
            P0[Pod: web-0<br/>web-0.service.ns.svc.cluster.local]
            P1[Pod: web-1<br/>web-1.service.ns.svc.cluster.local]
            P2[Pod: web-2<br/>web-2.service.ns.svc.cluster.local]
        end
        
        subgraph "Persistent Storage"
            PVC0[PVC: data-web-0<br/>10Gi]
            PVC1[PVC: data-web-1<br/>10Gi]
            PVC2[PVC: data-web-2<br/>10Gi]
        end
        
        subgraph "Physical Storage"
            PV0[PV: pv-001]
            PV1[PV: pv-002]
            PV2[PV: pv-003]
        end
        
        SS -->|Manages| P0
        SS -->|Manages| P1
        SS -->|Manages| P2
        
        HS -->|DNS: web-0| P0
        HS -->|DNS: web-1| P1
        HS -->|DNS: web-2| P2
        
        RS -->|Load Balance| P0
        RS -->|Load Balance| P1
        RS -->|Load Balance| P2
        
        P0 -.->|Mounts| PVC0
        P1 -.->|Mounts| PVC1
        P2 -.->|Mounts| PVC2
        
        PVC0 -->|Binds to| PV0
        PVC1 -->|Binds to| PV1
        PVC2 -->|Binds to| PV2
    end
    
    style SS fill:#326ce5,color:#fff
    style HS fill:#ff9900,color:#fff
    style RS fill:#ff9900,color:#fff
    style P0 fill:#13aa52,color:#fff
    style P1 fill:#13aa52,color:#fff
    style P2 fill:#13aa52,color:#fff
```

---

## 2. StatefulSet vs Deployment

```mermaid
graph LR
    subgraph "Deployment (Stateless)"
        D[Deployment]
        D --> DP1[Pod: app-7f8d9-a1b2c<br/>Random Name]
        D --> DP2[Pod: app-7f8d9-x9y8z<br/>Random Name]
        D --> DP3[Pod: app-7f8d9-m3n4o<br/>Random Name]
        
        DP1 -.->|Shares| SV[Shared Volume]
        DP2 -.->|Shares| SV
        DP3 -.->|Shares| SV
    end
    
    subgraph "StatefulSet (Stateful)"
        SS[StatefulSet]
        SS --> SP1[Pod: db-0<br/>Stable Name]
        SS --> SP2[Pod: db-1<br/>Stable Name]
        SS --> SP3[Pod: db-2<br/>Stable Name]
        
        SP1 -.->|Dedicated| PVC1[PVC: data-db-0]
        SP2 -.->|Dedicated| PVC2[PVC: data-db-1]
        SP3 -.->|Dedicated| PVC3[PVC: data-db-2]
    end
    
    style D fill:#326ce5,color:#fff
    style SS fill:#326ce5,color:#fff
    style DP1 fill:#999,color:#fff
    style DP2 fill:#999,color:#fff
    style DP3 fill:#999,color:#fff
    style SP1 fill:#13aa52,color:#fff
    style SP2 fill:#13aa52,color:#fff
    style SP3 fill:#13aa52,color:#fff
```

---

## 3. Ordered Deployment and Scaling

### Scale Up (0 → 3 replicas)

```mermaid
sequenceDiagram
    participant SS as StatefulSet
    participant P0 as Pod web-0
    participant P1 as Pod web-1
    participant P2 as Pod web-2
    
    Note over SS: Create web-0
    SS->>P0: Create Pod
    P0->>P0: Create PVC data-web-0
    P0->>P0: Start Container
    P0->>SS: Report: Running and Ready
    
    Note over SS: web-0 is Ready, create web-1
    SS->>P1: Create Pod
    P1->>P1: Create PVC data-web-1
    P1->>P1: Start Container
    P1->>SS: Report: Running and Ready
    
    Note over SS: web-1 is Ready, create web-2
    SS->>P2: Create Pod
    P2->>P2: Create PVC data-web-2
    P2->>P2: Start Container
    P2->>SS: Report: Running and Ready
    
    Note over SS,P2: All pods Running and Ready
```

### Scale Down (3 → 1 replicas)

```mermaid
sequenceDiagram
    participant SS as StatefulSet
    participant P0 as Pod web-0
    participant P1 as Pod web-1
    participant P2 as Pod web-2
    participant PVC2 as PVC data-web-2
    participant PVC1 as PVC data-web-1
    
    Note over SS: Delete web-2 (highest ordinal)
    SS->>P2: Terminate Pod
    P2->>P2: Graceful Shutdown
    P2->>SS: Pod Deleted
    Note over PVC2: PVC RETAINED (not deleted)
    
    Note over SS: web-2 deleted, now delete web-1
    SS->>P1: Terminate Pod
    P1->>P1: Graceful Shutdown
    P1->>SS: Pod Deleted
    Note over PVC1: PVC RETAINED (not deleted)
    
    Note over SS,P0: Only web-0 remains (and web-1, web-2 PVCs)
```

---

## 4. Pod Identity and DNS

```mermaid
graph TB
    subgraph "DNS Resolution"
        Client[Client Application]
        
        subgraph "Headless Service DNS"
            HS[Service: mysql-headless<br/>clusterIP: None]
        end
        
        subgraph "Pod DNS Entries"
            DNS0[mysql-0.mysql-headless<br/>.default.svc.cluster.local<br/>→ 10.1.1.5]
            DNS1[mysql-1.mysql-headless<br/>.default.svc.cluster.local<br/>→ 10.1.1.6]
            DNS2[mysql-2.mysql-headless<br/>.default.svc.cluster.local<br/>→ 10.1.1.7]
        end
        
        subgraph "Actual Pods"
            P0[Pod: mysql-0<br/>IP: 10.1.1.5<br/>PVC: data-mysql-0]
            P1[Pod: mysql-1<br/>IP: 10.1.1.6<br/>PVC: data-mysql-1]
            P2[Pod: mysql-2<br/>IP: 10.1.1.7<br/>PVC: data-mysql-2]
        end
        
        Client -->|Query specific pod| DNS0
        Client -->|Query specific pod| DNS1
        Client -->|Query specific pod| DNS2
        
        DNS0 -->|Resolves to| P0
        DNS1 -->|Resolves to| P1
        DNS2 -->|Resolves to| P2
        
        HS -.->|Manages DNS| DNS0
        HS -.->|Manages DNS| DNS1
        HS -.->|Manages DNS| DNS2
    end
    
    style Client fill:#ff6b6b,color:#fff
    style HS fill:#ff9900,color:#fff
    style P0 fill:#13aa52,color:#fff
    style P1 fill:#13aa52,color:#fff
    style P2 fill:#13aa52,color:#fff
```

---

## 5. PersistentVolumeClaim Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Creating: StatefulSet creates Pod
    Creating --> Pending: PVC created from template
    Pending --> Bound: PV allocated and bound
    Bound --> InUse: Pod mounts PVC
    
    InUse --> InUse: Pod restarts/reschedules
    InUse --> Released: Pod deleted
    Released --> InUse: Pod recreated, reattaches same PVC
    
    Released --> Deleted: Manual PVC deletion
    Deleted --> [*]
    
    note right of InUse
        PVC persists across
        pod deletions and
        recreations
    end note
    
    note right of Released
        StatefulSet deletion
        does NOT delete PVCs
        (by default)
    end note
```

---

## 6. Rolling Update Strategy

```mermaid
sequenceDiagram
    participant SS as StatefulSet
    participant P0 as web-0 (v1)
    participant P1 as web-1 (v1)
    participant P2 as web-2 (v1)
    participant NP2 as web-2 (v2)
    participant NP1 as web-1 (v2)
    participant NP0 as web-0 (v2)
    
    Note over SS: Update image to v2
    Note over SS: Delete web-2 (highest ordinal)
    
    SS->>P2: Terminate
    P2-->>SS: Terminated
    SS->>NP2: Create with v2 image
    NP2->>NP2: Attach to data-web-2
    NP2-->>SS: Running and Ready
    
    Note over SS: web-2 ready, delete web-1
    SS->>P1: Terminate
    P1-->>SS: Terminated
    SS->>NP1: Create with v2 image
    NP1->>NP1: Attach to data-web-1
    NP1-->>SS: Running and Ready
    
    Note over SS: web-1 ready, delete web-0
    SS->>P0: Terminate
    P0-->>SS: Terminated
    SS->>NP0: Create with v2 image
    NP0->>NP0: Attach to data-web-0
    NP0-->>SS: Running and Ready
    
    Note over SS,NP0: All pods updated to v2
```

---

## 7. Partition-Based Canary Deployment

```mermaid
graph TB
    subgraph "Canary Deployment with Partition=2"
        SS[StatefulSet<br/>partition: 2]
        
        subgraph "Updated Pods (ordinal >= 2)"
            P2[web-2<br/>Image: v2 NEW<br/>Status: Testing]
        end
        
        subgraph "Old Pods (ordinal < 2)"
            P0[web-0<br/>Image: v1<br/>Status: Stable]
            P1[web-1<br/>Image: v1<br/>Status: Stable]
        end
        
        SS -->|Updated| P2
        SS -->|Not Updated| P0
        SS -->|Not Updated| P1
        
        Client[Client Traffic]
        Client -->|Most traffic| P0
        Client -->|Most traffic| P1
        Client -->|Test traffic| P2
    end
    
    style SS fill:#326ce5,color:#fff
    style P2 fill:#ffd700,color:#000
    style P0 fill:#13aa52,color:#fff
    style P1 fill:#13aa52,color:#fff
```

---

## 8. Database Replication Example

```mermaid
graph TB
    subgraph "MySQL StatefulSet with Replication"
        subgraph "Master (Read/Write)"
            M[mysql-0<br/>Role: Master<br/>PVC: data-mysql-0<br/>Accepts Writes]
        end
        
        subgraph "Replicas (Read Only)"
            R1[mysql-1<br/>Role: Replica<br/>PVC: data-mysql-1<br/>Replicates from mysql-0]
            R2[mysql-2<br/>Role: Replica<br/>PVC: data-mysql-2<br/>Replicates from mysql-0]
        end
        
        M -->|Replication Stream| R1
        M -->|Replication Stream| R2
        
        App[Application]
        App -->|Writes| M
        App -->|Reads| R1
        App -->|Reads| R2
    end
    
    style M fill:#e74c3c,color:#fff
    style R1 fill:#3498db,color:#fff
    style R2 fill:#3498db,color:#fff
    style App fill:#95a5a6,color:#fff
```

---

## 9. StatefulSet Component Relationships

```mermaid
graph TD
    SS[StatefulSet]
    VCT[volumeClaimTemplates]
    PT[Pod Template]
    SVC[Service]
    SC[StorageClass]
    
    SS -->|Defines| VCT
    SS -->|Defines| PT
    SS -->|References| SVC
    VCT -->|Uses| SC
    
    subgraph "Created Resources"
        P0[Pod: app-0]
        P1[Pod: app-1]
        P2[Pod: app-2]
        PVC0[PVC: data-app-0]
        PVC1[PVC: data-app-1]
        PVC2[PVC: data-app-2]
    end
    
    SS -.->|Creates| P0
    SS -.->|Creates| P1
    SS -.->|Creates| P2
    
    VCT -.->|Generates| PVC0
    VCT -.->|Generates| PVC1
    VCT -.->|Generates| PVC2
    
    P0 -->|Mounts| PVC0
    P1 -->|Mounts| PVC1
    P2 -->|Mounts| PVC2
    
    SVC -->|Provides DNS for| P0
    SVC -->|Provides DNS for| P1
    SVC -->|Provides DNS for| P2
    
    style SS fill:#326ce5,color:#fff
    style SVC fill:#ff9900,color:#fff
```

---

## 10. Failure and Recovery Scenario

```mermaid
sequenceDiagram
    participant K8s as Kubernetes
    participant SS as StatefulSet
    participant Node as Node (Failed)
    participant P1 as Pod mysql-1
    participant PVC as PVC data-mysql-1
    participant NewNode as New Node
    participant NewP1 as New Pod mysql-1
    
    Note over P1,PVC: Pod running normally
    P1->>PVC: Using persistent storage
    
    Note over Node: Node fails!
    Node--xP1: Node unreachable
    
    K8s->>SS: Node failure detected
    SS->>SS: Wait for grace period
    
    Note over SS: Pod marked as Unknown
    SS->>NewNode: Schedule mysql-1 on new node
    
    NewNode->>NewP1: Create mysql-1
    NewP1->>PVC: Attach same PVC data-mysql-1
    Note over NewP1,PVC: Data preserved!
    
    NewP1->>NewP1: Start container
    NewP1->>SS: Report: Running and Ready
    
    Note over NewP1: mysql-1 recovers with<br/>same identity and data
```

---

## Summary

These diagrams illustrate key StatefulSet concepts:

1. **Architecture**: How StatefulSets manage pods, services, and storage
2. **Comparison**: Differences between StatefulSets and Deployments
3. **Ordering**: Sequential pod creation and deletion
4. **DNS**: Stable network identities via headless services
5. **PVC Lifecycle**: How persistent storage is managed
6. **Updates**: Rolling update and canary deployment strategies
7. **Replication**: Master/replica patterns for databases
8. **Recovery**: How StatefulSets handle failures

For practical examples, see:
- [Intermediate StatefulSet Guide](../../../../../../3-Advanced/01-Phase-1/04-Container-Orchestration/Advanced-K8s/StatefulSets)
- [Advanced StatefulSet Patterns](../../../../../../3-Advanced/01-Phase-1/04-Container-Orchestration/Advanced-K8s/StatefulSets)
