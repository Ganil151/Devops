# Lesson 02: Optimization Strategies

## Learning Objectives

By the end of this lesson, you will:
- Implement right-sizing strategies
- Eliminate cloud waste
- Optimize storage costs
- Use spot/preemptible instances effectively

---

## The Optimization Framework

```mermaid
graph TB
    subgraph "Optimization Priority"
        W[1. Waste Elimination] --> RS[2. Right-Sizing]
        RS --> SPOT[3. Spot/Preemptible]
        SPOT --> RI[4. Commitments]
        RI --> ARCH[5. Architecture]
    end
    
    style W fill:#2ecc71,stroke:#27ae60,color:#fff
    style RS fill:#3498db,stroke:#2980b9,color:#fff
    style SPOT fill:#f39c12,stroke:#d68910,color:#fff
    style RI fill:#9b59b6,stroke:#8e44ad,color:#fff
    style ARCH fill:#e74c3c,stroke:#c0392b,color:#fff
```

> 💡 **Start with quick wins**: Waste elimination and right-sizing before investing in commitments.

---

## 1. Waste Elimination

### Common Sources of Waste

| Waste Type | Description | Savings Potential |
|------------|-------------|-------------------|
| **Idle Resources** | Running but unused | 100% of resource |
| **Orphaned Storage** | Unattached volumes/snapshots | 100% of storage |
| **Oversized Resources** | More capacity than needed | 20-50% |
| **Old Snapshots** | Accumulated backups | 30-70% |
| **Unused IPs** | Elastic IPs not attached | $3.60/month each |

### Finding Waste: AWS

```bash
# Find unattached EBS volumes
aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query 'Volumes[*].[VolumeId,Size,CreateTime]' \
  --output table

# Find unused Elastic IPs
aws ec2 describe-addresses \
  --query 'Addresses[?InstanceId==`null`].[PublicIp,AllocationId]' \
  --output table

# Find old snapshots (>90 days)
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[?StartTime<=`2024-01-01`].[SnapshotId,VolumeSize,StartTime]' \
  --output table
```

### Finding Waste: Azure

```bash
# Find unattached disks
az disk list --query "[?diskState=='Unattached'].{Name:name,Size:diskSizeGb}"

# Find stopped VMs still incurring costs
az vm list -d --query "[?powerState!='VM running'].{Name:name,State:powerState}"
```

### Finding Waste: GCP

```bash
# Find unused disks
gcloud compute disks list --filter="NOT users:*"

# Find idle VMs (low CPU utilization)
gcloud recommender recommendations list \
  --recommender=google.compute.instance.IdleResourceRecommender \
  --location=us-central1-a
```

---

## 2. Right-Sizing

### What is Right-Sizing?

Matching resource allocation to actual utilization.

```mermaid
graph LR
    subgraph "Right-Sizing Example"
        OVER[m5.2xlarge<br>8 vCPU, 32GB<br>$280/month] --> RIGHT[m5.large<br>2 vCPU, 8GB<br>$70/month]
    end
    
    style OVER fill:#e74c3c,stroke:#c0392b,color:#fff
    style RIGHT fill:#2ecc71,stroke:#27ae60,color:#fff
```

### Right-Sizing Metrics

| Metric | Target Range | Action if Below |
|--------|--------------|-----------------|
| CPU Average | 40-70% | Downsize |
| Memory Average | 60-80% | Downsize |
| CPU Peak | <90% | Downsize |
| Memory Peak | <90% | Downsize |

### Using AWS Compute Optimizer

```bash
# Get EC2 recommendations
aws compute-optimizer get-ec2-instance-recommendations \
  --query 'instanceRecommendations[*].[instanceArn,currentInstanceType,recommendationOptions[0].instanceType,estimatedMonthlySavings.value]' \
  --output table
```

### Right-Sizing with CloudWatch

```bash
# Query average CPU over 14 days
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time $(date -d '14 days ago' --utc +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date --utc +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Average Maximum
```

---

## 3. Spot/Preemptible Instances

### When to Use Spot Instances

```mermaid
graph TB
    subgraph "Spot Instance Decision"
        Q1{Fault Tolerant?}
        Q1 -->|Yes| Q2{Flexible Timing?}
        Q1 -->|No| NO[❌ Not Suitable]
        Q2 -->|Yes| Q3{Stateless?}
        Q2 -->|No| NO
        Q3 -->|Yes| YES[✅ Use Spot]
        Q3 -->|No| MAYBE[⚠️ With Persistence]
    end
    
    style YES fill:#2ecc71,stroke:#27ae60,color:#fff
    style NO fill:#e74c3c,stroke:#c0392b,color:#fff
    style MAYBE fill:#f39c12,stroke:#d68910,color:#fff
```

### Good Spot Use Cases

| Use Case | Why It Works |
|----------|--------------|
| CI/CD builds | Short-lived, restartable |
| Batch processing | Checkpointable workloads |
| Dev/Test | Non-critical environments |
| Data processing | Stateless transformations |
| Container workloads | Easily rescheduled |

### Spot Best Practices

| Practice | Description |
|----------|-------------|
| **Diversify** | Use multiple instance types |
| **Handle interruption** | Implement graceful shutdown |
| **Mix with On-Demand** | Base capacity + Spot scaling |
| **Use Spot Fleets** | Automatic instance selection |
| **Set max price** | Limit hourly spend |

### AWS Spot Fleet Example

```json
{
  "SpotFleetRequestConfig": {
    "TargetCapacity": 10,
    "IamFleetRole": "arn:aws:iam::123456789012:role/spot-fleet-role",
    "LaunchSpecifications": [
      {
        "InstanceType": "m5.large",
        "WeightedCapacity": 1,
        "SpotPrice": "0.05"
      },
      {
        "InstanceType": "m5.xlarge",
        "WeightedCapacity": 2,
        "SpotPrice": "0.10"
      },
      {
        "InstanceType": "m4.large",
        "WeightedCapacity": 1,
        "SpotPrice": "0.04"
      }
    ],
    "AllocationStrategy": "lowestPrice"
  }
}
```

---

## 4. Storage Optimization

### Storage Tiers

| Tier | AWS | Azure | GCP | Use Case |
|------|-----|-------|-----|----------|
| **Hot** | S3 Standard | Hot | Standard | Frequent access |
| **Warm** | S3 IA | Cool | Nearline | Monthly access |
| **Cold** | S3 Glacier | Archive | Coldline | Yearly access |
| **Archive** | Glacier Deep | Archive | Archive | Compliance |

### Storage Savings by Tier

```mermaid
pie title Storage Cost per GB/month
    "S3 Standard ($0.023)" : 23
    "S3 IA ($0.0125)" : 12.5
    "S3 Glacier ($0.004)" : 4
    "Glacier Deep ($0.00099)" : 1
```

### Implementing Lifecycle Policies

**AWS S3 Lifecycle:**
```json
{
  "Rules": [
    {
      "ID": "TransitionToIA",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        },
        {
          "Days": 365,
          "StorageClass": "DEEP_ARCHIVE"
        }
      ],
      "Expiration": {
        "Days": 2555
      }
    }
  ]
}
```

### EBS Optimization

| Optimization | Savings | Effort |
|--------------|---------|--------|
| Delete unattached volumes | 100% | Low |
| Use gp3 instead of gp2 | 20% | Low |
| Right-size volumes | Varies | Medium |
| Snapshot lifecycle | 30-50% | Medium |

---

## 5. Network Optimization

### Data Transfer Costs

```mermaid
graph LR
    subgraph "Data Transfer Pricing"
        IN[Inbound<br>FREE] --> CLOUD[Cloud]
        CLOUD --> OUT[Outbound<br>$0.09/GB]
        CLOUD --> CROSS[Cross-Region<br>$0.02/GB]
        AZ1[AZ1] <--> AZ2[AZ2<br>$0.01/GB]
    end
    
    style IN fill:#2ecc71,stroke:#27ae60,color:#fff
    style OUT fill:#e74c3c,stroke:#c0392b,color:#fff
    style CROSS fill:#f39c12,stroke:#d68910,color:#fff
```

### Network Optimization Strategies

| Strategy | Description | Savings |
|----------|-------------|---------|
| **CDN** | Cache at edge locations | 40-60% on egress |
| **Same-Region** | Keep resources together | Eliminate cross-region |
| **VPC Endpoints** | Avoid NAT Gateway | Variable |
| **Compression** | Reduce data size | Proportional to compression |
| **Caching** | Reduce repeated transfers | 50-90% |

---

## Optimization Checklist

### Weekly Tasks
- [ ] Review unused resource alerts
- [ ] Check for new optimization recommendations
- [ ] Validate scheduled shutdown compliance

### Monthly Tasks
- [ ] Run right-sizing analysis
- [ ] Review storage lifecycle policies
- [ ] Analyze spot instance savings
- [ ] Update optimization dashboard

### Quarterly Tasks
- [ ] Comprehensive waste audit
- [ ] Architecture review for cost efficiency
- [ ] Reserved instance coverage review

---

## Key Takeaways

- ✅ Eliminate waste first (100% savings on unused resources)
- ✅ Right-size to match utilization (20-50% savings)
- ✅ Use Spot for fault-tolerant workloads (60-90% savings)
- ✅ Implement storage lifecycle policies (70%+ on cold data)
- ✅ Optimize network architecture to reduce data transfer

---

## Next Lesson

Continue to **[Lesson 03: Reserved Instances & Savings Plans](../03-Reserved-Instances/README.md)** to learn about commitment-based discounts.
