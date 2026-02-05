# ETCD in Kubernetes Control Plane

## Overview

**etcd** is a distributed, reliable key-value store that serves as Kubernetes' primary datastore. It stores all cluster data including configuration data, state information, and metadata. As the single source of truth for the entire Kubernetes cluster, etcd is critical for cluster operations and consistency.

## What is etcd?

etcd (pronounced "et-see-dee") is:
- A distributed key-value store
- Written in Go programming language
- Uses the Raft consensus algorithm
- Provides strong consistency guarantees
- Highly available and fault-tolerant

## Role in Kubernetes Architecture

### Primary Functions

1. **Cluster State Storage**
   - Stores all Kubernetes objects (Pods, Services, Deployments, etc.)
   - Maintains cluster configuration and metadata
   - Tracks resource quotas and limits

2. **Configuration Management**
   - Stores cluster-wide configuration
   - Maintains API server configuration
   - Stores network policies and RBAC rules

3. **Service Discovery**
   - Maintains service endpoints
   - Stores DNS configuration
   - Tracks node information

## Data Stored in etcd

### Kubernetes Objects
```
/registry/pods/default/my-pod
/registry/services/default/my-service
/registry/deployments/default/my-deployment
/registry/configmaps/default/my-config
/registry/secrets/default/my-secret
```

### Cluster Information
- Node registration and status
- Cluster events and audit logs
- Resource quotas and limits
- Network policies
- RBAC policies and bindings

## etcd Architecture

### Raft Consensus Algorithm

etcd uses the Raft consensus algorithm to ensure:
- **Leader Election**: One node acts as leader
- **Log Replication**: Changes are replicated to followers
- **Safety**: Consistent state across all nodes

### Cluster Topology

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    etcd-1   │    │    etcd-2   │    │    etcd-3   │
│   (Leader)  │◄──►│  (Follower) │◄──►│  (Follower) │
└─────────────┘    └─────────────┘    └─────────────┘
```

## Deployment Models

### 1. Stacked etcd Topology
- etcd runs on the same nodes as control plane components
- Simpler to set up and manage
- Fewer nodes required

```
┌─────────────────────────────┐
│     Control Plane Node      │
│  ┌─────────┐ ┌───────────┐  │
│  │ API     │ │   etcd    │  │
│  │ Server  │ │           │  │
│  └─────────┘ └───────────┘  │
│  ┌─────────┐ ┌───────────┐  │
│  │Scheduler│ │Controller │  │
│  │         │ │ Manager   │  │
│  └─────────┘ └───────────┘  │
└─────────────────────────────┘
```

### 2. External etcd Topology
- etcd runs on separate dedicated nodes
- Better isolation and performance
- More resilient to failures

```
┌─────────────────┐    ┌─────────────────┐
│ Control Plane   │    │  etcd Cluster   │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ API Server  │◄┼────┼►│    etcd     │ │
│ └─────────────┘ │    │ └─────────────┘ │
│ ┌─────────────┐ │    └─────────────────┘
│ │ Scheduler   │ │
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ Controller  │ │
│ │ Manager     │ │
│ └─────────────┘ │
└─────────────────┘
```

## High Availability Configuration

### Cluster Size Recommendations

| Cluster Size | Fault Tolerance | Use Case |
|--------------|-----------------|----------|
| 1 node | 0 failures | Development/Testing |
| 3 nodes | 1 failure | Small Production |
| 5 nodes | 2 failures | Large Production |
| 7 nodes | 3 failures | Critical Production |

### Quorum Requirements
- Minimum nodes for quorum: `(n/2) + 1`
- 3-node cluster: requires 2 nodes
- 5-node cluster: requires 3 nodes

## Performance Characteristics

### Key Metrics
- **Latency**: Typically < 10ms for writes
- **Throughput**: ~10,000 writes/second
- **Storage**: Recommended < 8GB database size
- **Network**: Requires low-latency network

### Performance Tuning
```yaml
# etcd configuration
heartbeat-interval: 100
election-timeout: 1000
max-snapshots: 5
max-wals: 5
quota-backend-bytes: 2147483648  # 2GB
```

## Security Features

### Authentication & Authorization
- **Client certificates**: mTLS authentication
- **RBAC**: Role-based access control
- **User management**: Built-in user database

### Encryption
- **Encryption at rest**: AES encryption for stored data
- **Encryption in transit**: TLS for all communications

### Security Configuration
```yaml
# Security settings
client-cert-auth: true
trusted-ca-file: /etc/kubernetes/pki/etcd/ca.crt
cert-file: /etc/kubernetes/pki/etcd/server.crt
key-file: /etc/kubernetes/pki/etcd/server.key
peer-client-cert-auth: true
peer-trusted-ca-file: /etc/kubernetes/pki/etcd/ca.crt
peer-cert-file: /etc/kubernetes/pki/etcd/peer.crt
peer-key-file: /etc/kubernetes/pki/etcd/peer.key
```

## Backup and Recovery

### Backup Strategies

#### 1. Snapshot Backup
```bash
# Create snapshot
etcdctl snapshot save backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Verify snapshot
etcdctl snapshot status backup.db --write-out=table
```

#### 2. Automated Backup
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: etcd-backup
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: etcd-backup
            image: k8s.gcr.io/etcd:3.5.0
            command:
            - /bin/sh
            - -c
            - etcdctl snapshot save /backup/etcd-$(date +%Y%m%d-%H%M%S).db
```

### Recovery Process

#### 1. Stop etcd
```bash
systemctl stop etcd
```

#### 2. Restore from snapshot
```bash
etcdctl snapshot restore backup.db \
  --data-dir=/var/lib/etcd-restore \
  --name=etcd-1 \
  --initial-cluster=etcd-1=https://10.0.0.1:2380 \
  --initial-advertise-peer-urls=https://10.0.0.1:2380
```

#### 3. Update configuration and restart
```bash
# Update data directory in etcd config
# Restart etcd service
systemctl start etcd
```

## Monitoring and Troubleshooting

### Key Metrics to Monitor

#### Health Metrics
- **etcd_server_health**: Overall cluster health
- **etcd_server_leader_changes_seen_total**: Leader election frequency
- **etcd_server_proposals_failed_total**: Failed proposals

#### Performance Metrics
- **etcd_disk_wal_fsync_duration_seconds**: WAL fsync latency
- **etcd_disk_backend_commit_duration_seconds**: Backend commit latency
- **etcd_server_slow_apply_total**: Slow apply operations

#### Resource Metrics
- **etcd_mvcc_db_total_size_in_bytes**: Database size
- **etcd_server_quota_backend_bytes**: Backend quota
- **process_resident_memory_bytes**: Memory usage

### Health Check Commands

```bash
# Check cluster health
etcdctl endpoint health \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Check cluster status
etcdctl endpoint status \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --write-out=table

# List cluster members
etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

## Common Issues and Solutions

### 1. Split Brain Scenario
**Problem**: Network partition causes multiple leaders
**Solution**: 
- Ensure odd number of nodes
- Implement proper network monitoring
- Use anti-affinity rules for node placement

### 2. Database Size Growth
**Problem**: etcd database grows too large
**Solution**:
```bash
# Compact old revisions
etcdctl compact $(etcdctl endpoint status --write-out="json" | jq -r '.[] | .Status.header.revision')

# Defragment database
etcdctl defrag --endpoints=https://127.0.0.1:2379
```

### 3. High Latency
**Problem**: Slow etcd operations
**Solutions**:
- Check disk I/O performance
- Verify network latency between nodes
- Monitor CPU and memory usage
- Consider SSD storage for better performance

### 4. Certificate Expiration
**Problem**: TLS certificates expire
**Solution**:
```bash
# Check certificate expiration
openssl x509 -in /etc/kubernetes/pki/etcd/server.crt -text -noout | grep "Not After"

# Renew certificates (kubeadm)
kubeadm certs renew etcd-server
kubeadm certs renew etcd-peer
kubeadm certs renew etcd-healthcheck-client
```

## Best Practices

### 1. Infrastructure
- Use dedicated nodes for etcd in production
- Ensure fast, reliable storage (SSD recommended)
- Implement proper network security
- Use separate network for etcd cluster communication

### 2. Configuration
- Set appropriate resource limits
- Configure proper backup retention
- Enable audit logging
- Use encryption at rest and in transit

### 3. Operations
- Regular backup testing
- Monitor cluster health continuously
- Plan for disaster recovery scenarios
- Keep etcd version updated

### 4. Security
- Use strong authentication mechanisms
- Implement network policies
- Regular security audits
- Principle of least privilege for access

## Integration with Kubernetes Components

### API Server Integration
```yaml
# kube-apiserver configuration
--etcd-servers=https://10.0.0.1:2379,https://10.0.0.2:2379,https://10.0.0.3:2379
--etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
--etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
--etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
```

### Watch Mechanism
- API Server watches etcd for changes
- Efficient event-driven updates
- Reduces polling overhead
- Enables real-time cluster state synchronization

## Conclusion

etcd is the backbone of Kubernetes cluster state management. Understanding its architecture, configuration, and operational aspects is crucial for:
- Ensuring cluster reliability
- Maintaining data consistency
- Implementing proper backup strategies
- Troubleshooting cluster issues
- Optimizing cluster performance

Proper etcd management directly impacts the overall health and performance of your Kubernetes cluster.