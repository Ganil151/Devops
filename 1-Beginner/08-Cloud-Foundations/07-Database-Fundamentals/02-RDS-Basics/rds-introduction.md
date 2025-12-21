# Amazon RDS Introduction

## What is Amazon RDS?

Amazon Relational Database Service (RDS) is a managed database service that makes it easy to set up, operate, and scale relational databases in the cloud. AWS handles the heavy lifting of database administration so you can focus on your applications.

## Why Use RDS Instead of Self-Managed Databases?

### Traditional Approach (Self-Managed)
```
Your Responsibilities:
├── ❌ Install and configure database software
├── ❌ Set up server hardware/EC2 instances
├── ❌ Configure backups and recovery
├── ❌ Apply security patches
├── ❌ Monitor and optimize performance
├── ❌ Set up high availability
└── ❌ Scale infrastructure as needed

Time spent: 40-60% on infrastructure, 40-60% on application
```

### RDS Approach (AWS-Managed)
```
Your Responsibilities:
├── ✅ Design database schema
├── ✅ Write application queries
└── ✅ Optimize application performance

AWS Handles:
├── ✅ Automated backups
├── ✅ Software patching
├── ✅ Hardware provisioning
├── ✅ High availability setup
├── ✅ Scaling capabilities
└── ✅ Monitoring and alerts

Time spent: 5-10% on infrastructure, 90-95% on application
```

## Supported Database Engines

RDS supports six popular database engines:
![RDS Supported Database Engines](.../../../../../../../../00-Resources/03-Images-Diagrams/AWS/databasesEngines.png)

### Quick Comparison

**MySQL**: Open-source, widely used, great for web apps
```bash
# Common use cases
- WordPress, Drupal websites
- E-commerce platforms
- Mobile app backends
```

**PostgreSQL**: Advanced features, extensible
```bash
# Common use cases
- Data warehousing
- GIS applications (PostGIS)
- JSON/document storage
```

**MariaDB**: MySQL fork, additional features
```bash
# Common use cases
- MySQL migration path
- When you need newer features
```

**Oracle**: Enterprise-grade,legacy support
```bash
# Common use cases
- Large enterprise applications
- Migrating from on-premises Oracle
```

**SQL Server**: Windows/.NET integration
```bash
# Common use cases
- .NET applications
- Microsoft ecosystem
```

## Key Features

### 1. Automated Backups
```
Daily Backups:
├── Automatic daily snapshots
├── Transaction log backups (every 5 minutes)
├── Point-in-time recovery
├── Retention: 1-35 days
└── Zero downtime for backups
```

### 2. High Availability (Multi-AZ)
![multi-AZ](.../../../../../../../../00-Resources/03-Images-Diagrams/AWS/multi-Az-Deployment.png)



### 3. Read Replicas
![ReadReplicas](../../../../../../00-Resources/03-Images-Diagrams/AWS/replicaDeployment.png)

### 4. Automatic Scaling
![autoScaling](../../../../../../00-Resources/03-Images-Diagrams/AWS/storageAutoScaling.png)

### 5. Security Features
```
Security Layers:
├── Network isolation (VPC)
├── Encryption at rest (AES-256)
├── Encryption in transit (SSL/TLS)
├── IAM database authentication
├── Security groups (firewall rules)
└── Automated backups (encrypted)
```

## RDS Instance Types

### General Purpose  (T3, M5)
**Use for**: Development test, small-to-medium applications
```
db.t3.micro:  1 vCPU, 1 GB RAM    ~$15/month
db.t3.small:  2 vCPU, 2 GB RAM    ~$30/month
db.m5.large:  2 vCPU, 8 GB RAM    ~$120/month
```

### Memory Optimized (R5, X1)
**Use for**: High-performance databases, large datasets
```
db.r5.large:    2 vCPU, 16 GB RAM   ~$180/month
db.r5.xlarge:   4 vCPU, 32 GB RAM   ~$360/month
db.r5.4xlarge: 16 vCPU, 128 GB RAM  ~$1,440/month
```

### Burstable (T3)
**Use for**: Variable workloads, development
```
CPU Credits System:
├── Earn credits when idle
├── Spend credits when busy
└── Baseline performance + burst capability
```

## Storage Types

| Type | IOPS | Use Case | Cost |
|------|------|----------|------|
| **General Purpose (gp3)** | 3,000-16,000 | Most workloads | $0.115/GB |
| **Provisioned IOPS (io1)** | Up to 64,000 | I/O intensive | $0.125/GB + IOPS cost |
| **Magnetic** | ~100 | Legacy, archival | $0.10/GB |

**Recommendation**: Use gp3 for 95% of workloads

## Pricing Overview

### Components
```
Monthly RDS Cost:
├── Instance hours ($15-$10,000+/month)
├── Storage ($0.115/GB/month)
├── Backup storage (free = snapshot size)
├── Data transfer (varies)
└── Optional: Multi-AZ (2x instance cost)
```

### Example: Small Web App
```
db.t3.small (2 vCPU, 2 GB RAM)
├── Instance:     $30/month
├── Storage (50GB): $6/month
├── Backups:      $0 (within DB size)
└── Multi-AZ:     +$30/month (optional)
────────────────────────────────
Total: ~$36-66/month
```

### Free Tier
```
AWS Free Tier (12 months):
├── 750 hours/month of db.t2.micro or db.t3.micro
├── 20 GB of General Purpose (SSD) storage
├── 20 GB of backup storage
└── Enough for small development/testing
```

## When to Use RDS

### ✅ Perfect Use Cases:

**Web Applications**
```
WordPress, Drupal, e-commerce platforms
- Managed backups
- Easy scaling
- High availability
```

**Mobile Backends**
```
User data, authentication, app state
- Low maintenance
- Global reach (read replicas)
- Automatic backups
```

**Line-of-Business Apps**
```
CRM, ERP, HR systems
- Familiar SQL
- ACID transactions
- Compliance features
```

### ❌ Not Ideal For:

**Simple Key-Value Storage**
```
Use DynamoDB instead
```

**Massive Scale (millions of writes/sec)**
```
Use DynamoDB or custom solution
```

**Complete Control Needed**
```
Use EC2 with self-managed database
```

## RDS vs Aurora

| Feature | RDS | Aurora |
|---------|-----|--------|
| **Performance** | Standard | 5x MySQL, 3x PostgreSQL |
| **Storage** | Up to 64 TB | Up to 128 TB |
| **Replicas** | 5 read replicas | 15 read replicas |
| **Failover** | 60-120 seconds | < 30 seconds |
| **Pricing** | Lower base cost | Higher cost, better value at scale |
| **Use When** | Standard workloads | High performance needed |

## Common RDS Configurations

### Development/Test
```yaml
Engine: MySQL 8.0
Instance: db.t3.micro
Storage: 20 GB gp3
Multi-AZ: No
Backups: 7 days
Cost: ~$15/month (Free Tier eligible)
```

### Production Web App
```yaml
Engine: PostgreSQL 14
Instance: db.t3.small
Storage: 100 GB gp3
Multi-AZ: Yes
Backups: 14 days
Read Replicas: 1
Cost: ~$120/month
```

### Enterprise Application
```yaml
Engine: SQL Server
Instance: db.m5.large
Storage: 500 GB gp3
Multi-AZ: Yes
Backups: 30 days
Cost: ~$800/month
```

## Quick Start Checklist

Before creating your first RDS instance:

- [ ] Decide on database engine (MySQL, PostgreSQL, etc.)
- [ ] Choose instance type (start with t3.micro for Free Tier)
- [ ] Determine storage size (start small, auto-scale)
- [ ] Plan network (VPC, security groups)
- [ ] Consider Multi-AZ for production
- [ ] Set backup retention period
- [ ] Understand pricing

## Best Practices Summary

1. **Start Small**: Use Free Tier, scale as needed
2. **Enable Backups**: Minimum 7 days retention
3. **Use Multi-AZ**: For production workloads
4. **Secure Access**: Use VPC, security groups, encryption
5. **Monitor Performance**: Enable Enhanced Monitoring
6. **Plan Maintenance**: Choose low-traffic windows
7. **Test Restoration**: Periodically test backup recovery

## Comparison: RDS vs Self-Managed

| Task | RDS | Self-Managed EC2 |
|------|-----|------------------|
| **Setup Time** | 10 minutes | 2-4 hours |
| **Backups** | Automatic | Manual setup |
| **Patching** | Automatic | Manual |
| **High Availability** | Click to enable | Complex setup |
| **Scaling** | Modify instance | Recreate server |
| **Monitoring** | Built-in | Setup CloudWatch |
| **Cost** | Slightly higher | Lower base, higher ops |
| **Operational Overhead** | Minimal | Significant |

## Next Steps

Ready to create your first RDS database?

1. **[RDS Getting Started](./rds-getting-started.md)** - Step-by-step guide to create your first RDS instance
2. **[RDS Backups & Snapshots](./rds-backups-snapshots.md)** - Learn about data protection
3. **[Intermediate RDS](../../Intermediate-Level/09-Database-Services/01-RDS-Advanced/)** - Advanced features

## Additional Resources

- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [RDS Pricing Calculator](https://calculator.aws/)
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)
- [RDS Free Tier](https://aws.amazon.com/rds/free/)

## Key Takeaways

- 🚀 RDS manages database administration for you
- 🔒 Built-in security, backups, and high availability
- 💰 Free Tier available for learning and small projects
- ⚡ Six database engines to choose from
- 📊 Scales from small dev environments to enterprise workloads
- 🎯 Focus on your application, not infrastructure

---

**Ready to build?** Continue to [RDS Getting Started](./rds-getting-started.md) to create your first database!
