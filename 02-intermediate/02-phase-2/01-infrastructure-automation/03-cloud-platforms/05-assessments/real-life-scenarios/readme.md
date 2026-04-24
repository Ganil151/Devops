# 09: Real-Life Scenarios

Explore how Cloud Engineering principles are applied to solve complex production problems.

## 🛠️ Scenario 1: Developing a Multi-Region Disaster Recovery Plan
**Context**: Your company's main application runs in `us-east-1`. A major regional outage occurs, and the business loses $50k/hour.
**Challenge**: Ensure the application can failover to `us-west-2` with a Recovery Time Objective (RTO) of less than 1 hour.
**Solution**:
1. **Database**: Use **RDS Read Replicas** in `us-west-2` and promote them to master during failover (or use Aurora Global Database).
2. **Storage**: Enable **S3 Cross-Region Replication** for all critical data buckets.
3. **Compute**: Maintain an **AMI (Amazon Machine Image)** or a Docker image in the secondary region. Use **Terraform** to spin up the infrastructure (ASG, ALB) in the new region quickly.
4. **Networking**: Use **Route 53 Failover Routing** with health checks to automatically point users to the secondary region's Load Balancer.

---

## 📈 Scenario 2: Auto Scaling for "Black Friday" Traffic Spikes
**Context**: An e-commerce site expects a 10x increase in traffic during a 48-hour sale period.
**Challenge**: Scale the infrastructure to handle the load without overspending or crashing.
**Solution**:
1. **Proactive Scaling**: Use **Scheduled Scaling** in the Auto Scaling Group (ASG) to pre-provision instances before the sale starts.
2. **Dynamic Scaling**: Configure **Target Tracking Scaling Policies** based on `RequestCountPerTarget` or `Average CPU Utilization`.
3. **Caching**: Utilize **CloudFront** for static assets and **ElastiCache (Redis)** to reduce database load.
4. **Database**: Ensure **RDS Storage Auto Scaling** is enabled and consider a larger instance size for the sale duration.

---

## 🔒 Scenario 3: Remediation of an IAM Security Breach
**Context**: An employee inadvertently committed an AWS Access Key and Secret Key to a public GitHub repository. Within minutes, unauthorized EC2 instances were launched in several regions.
**Challenge**: Contain the breach and harden the account.
**Solution**:
1. **Containment**: Immediately **Deactivate/Delete** the compromised IAM user's access keys.
2. **Cleanup**: Use a tool like `aws-nuke` (carefully) or manual inspection to terminate unauthorized instances and delete rogue resources.
3. **Prevention**: Implement **IAM Roles** for EC2 instances instead of using hardcoded keys.
4. **Automation**: Enable **AWS GuardDuty** to detect similar activity and use **Secrets Manager** with rotation.

---

## 🏗️ Scenario 4: Centralized Logging and Governance (Multi-Account)
**Context**: A large enterprise has 50+ AWS accounts across different departments. Security needs a single place to view all logs.
**Challenge**: Consolidate logs and ensure compliance across all accounts.
**Solution**:
1. **Organization**: Use **AWS Organizations** to manage accounts.
2. **Logging**: Create a dedicated **Centralized Logging Account**.
3. **Log Collection**: Use **CloudWatch Logs Destination** and **Kinesis Data Firehose** to stream logs from all accounts into a single S3 bucket in the logging account.
4. **Governance**: Enable **AWS Control Tower** and **Guardrails** (Service Control Policies - SCPs) to prevent users from disabling logging or creating resources in unauthorized regions.

---

## ⚡ Scenario 5: Migrating from Monolith to Serverless
**Context**: A simple legacy cron job runs on an expensive, underutilized t3.large EC2 instance 24/7.
**Challenge**: Reduce costs and maintenance overhead.
**Solution**:
1. **Extraction**: Rewrite the cron job logic into a Python script.
2. **Architecture**: Deploy the script as an **AWS Lambda** function.
3. **Trigger**: Use **Amazon EventBridge (CloudWatch Events)** to trigger the Lambda on the same schedule (e.g., every hour).
4. **Cost Benefit**: Switch from paying $60+/month to paying only for the few seconds the Lambda runs (likely within the Free Tier).
