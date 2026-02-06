# 🔄 Data Backup and Disaster Recovery

Disaster Recovery (DR) is the process by which an organization anticipates and addresses technology-related disasters.

![Backup Architecture Placeholder](descriptive-diagram:-a-backup-lifecycle-showing-daily-snapshots,-cross-account-vaulting-for-ransomware-protection,-and-a-restoration-path-to-a-different-region.)

## 🚀 The "DevOps Why": RTO and RPO
Every backup strategy is defined by two metrics:
1. **RTO (Recovery Time Objective)**: The maximum acceptable delay between the interruption of service and restoration of service.
2. **RPO (Recovery Point Objective)**: The maximum acceptable amount of data loss measured in time.

---

## 🏗️ Backup Patterns

### 1. Automated Snapshots
Standard incremental backups of block storage (EBS) or databases (RDS). These are stored in object storage (S3) for durability.

### 2. Point-In-Time Recovery (PITR)
The ability to restore a database to a specific second within a retention period (usually 35 days). This is achieved by combining daily snapshots with transaction logs.

### 3. Air-Gapped Backups (Backup Vaults)
Copying backups to a separate, restricted account to prevent a "compromised root user" from deleting all backups during a ransomware attack.

---

### 💰 FinOps Tip: Cold Storage Backups
Move older snapshots to "Cold" tiers (e.g., AWS Backup Archive) for long-term retention. Keeping 5 years of snapshots in "Warm" storage is an unnecessary expense.

---

## 📂 Implementation Guides
- [Backup-Strategies](../../../02-config-management/02-iac-foundations-and-terraform/01-fundamentals/20-testing-strategies/testing-strategies.md): Planning for 3-2-1 backup methodology.
- [DR-Patterns](../../../02-config-management/00-reference-and-metadata/iac-architecture-patterns-ref.md): Pilot Light vs. Warm Standby vs. Multi-Site.
