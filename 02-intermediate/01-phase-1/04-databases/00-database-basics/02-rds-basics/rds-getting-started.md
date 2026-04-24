# Amazon RDS Getting Started - Hands-On Guide

## Introduction

This hands-on guide walks you through creating your first Amazon RDS database instance. You'll learn both console and CLI methods, connect to your database, and perform basic operations.

## What You'll Build

```
Your RDS Setup:
┌──────────────────────────────────────────────┐
│ VPC: Your existing or default VPC            │
│                                               │
│  ┌────────────────────────────────────┐     │
│  │ DB Subnet Group                    │     │
│  │  ┌──────────┐      ┌──────────┐   │     │
│  │  │ Subnet 1 │      │ Subnet 2 │   │     │
│  │  │ (AZ-1a)  │      │ (AZ-1b)  │   │     │
│  │  └──────────┘      └──────────┘   │     │
│  └────────────────────────────────────┘     │
│           │                                  │
│  ┌────────▼──────────────┐                  │
│  │ RDS Instance          │                  │
│  │ - MySQL 8.0          │                  │
│  │ - db.t3.micro        │                  │
│  │ - 20 GB storage      │                  │
│  └───────────────────────┘                  │
│           │                                  │
│  ┌────────▼──────────────┐                  │
│  │ Security Group        │                  │
│  │ Port 3306            │                  │
│  └───────────────────────┘                  │
└──────────────────────────────────────────────┘
```

## Prerequisites

- AWS Account
- AWS CLI installed and configured
- Basic understanding of databases
- VPC with at least 2 subnets in different AZs (or use default VPC)

**Time Required**: 20-30 minutes  
**Cost**: Free Tier eligible (db.t3.micro, 20 GB) or ~$15/month

## Step 1: Plan Your Database

### Choose Your Database Engine

| Engine | Best For | Learning Curve |
|--------|----------|----------------|
| **MySQL** | Web apps, WordPress | Easy |
| **PostgreSQL** | Complex queries, JSON | Medium |
| **MariaDB** | MySQL alternative | Easy |
| **Oracle** | Enterprise apps | Hard |
| **SQL Server** | .NET apps | Medium |

**For this tutorial**: We'll use **MySQL 8.0** (most popular, widely supported)

### Size Your Instance

**Free Tier Eligible**:
- Instance: db.t3.micro (1 vCPU, 1 GB RAM)
- Storage: 20 GB General Purpose (SSD)
- Backups: 20 GB backup storage

**Cost**: $0 for 12 months, then ~$15/month

## Step 2: Create DB Subnet Group

RDS requires a DB subnet group spanning at least 2 Availability Zones.

### Using AWS Console

1. Navigate to **RDS** → **Subnet groups** → **Create DB subnet group**
2. Settings:
   - Name: `my-db-subnet-group`
   - Description: `Subnet group for tutorial`
   - VPC: Select your VPC
   - Availability Zones: Select 2 AZs
   - Subnets: Select one subnet per AZ

### Using AWS CLI

```bash
#1. Get your VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' \
  --output text)

echo "Using VPC: $VPC_ID"

# 2. Get subnet IDs (need at least 2 in different AZs)
SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[0:2].SubnetId' \
  --output text | tr '\t' ' ')

echo "Using Subnets: $SUBNET_IDS"

# 3. Create DB subnet group
aws rds create-db-subnet-group \
  --db-subnet-group-name my-db-subnet-group \
  --db-subnet-group-description "Subnet group for tutorial" \
  --subnet-ids $SUBNET_IDS \
  --tags Key=Name,Value=tutorial-db-subnet-group

echo "✅ DB Subnet Group created"
```

## Step 3: Create Security Group

Security group controls network access to your RDS instance.

```bash
# 1. Create security group
DB_SG_ID=$(aws ec2 create-security-group \
  --group-name rds-mysql-sg \
  --description "Security group for RDS MySQL" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

echo "Security Group ID: $DB_SG_ID"

# 2. Allow MySQL port (3306) from your IP
MY_IP=$(curl -s ifconfig.me)

aws ec2 authorize-security-group-ingress \
  --group-id $DB_SG_ID \
  --protocol tcp \
  --port 3306 \
  --cidr "$MY_IP/32"

echo "✅ MySQL port opened for your IP: $MY_IP"

# For testing: Allow from VPC CIDR (more permissive)
# VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID \
#   --query 'Vpcs[0].CidrBlock' --output text)
# aws ec2 authorize-security-group-ingress \
#   --group-id $DB_SG_ID \
#   --protocol tcp \
#   --port 3306 \
#   --cidr "$VPC_CIDR"
```

**Security Note**: In production, only allow access from application security groups, not public IPs!

## Step 4: Create RDS Instance (Console)

### Step-by-Step Console Guide

**1. Navigate to RDS**
- AWS Console → RDS → Databases → **Create database**

**2. Choose Engine**
- Engine type: **MySQL**
- Version: **MySQL 8.0.35** (latest stable)
- Templates: **Free tier** (or Dev/Test)

**3. Settings**
```
DB instance identifier: my-first-database
Master username: admin
Master password: <choose-strong-password>
Confirm password: <repeat-password>
```

**4. Instance Configuration**
- DB instance class: **db.t3.micro** (Free Tier)
- Storage type: **General Purpose SSD (gp3)**
- Allocated storage: **20 GB**
- Storage autoscaling: **Enabled** (max 100 GB)

**5. Connectivity**
- VPC: Select your VPC
- DB subnet group: `my-db-subnet-group`
- Public access: **No** (recommended) or **Yes** (for testing)
- VPC security group: Select `rds-mysql-sg`
- Availability Zone: **No preference**

**6. Additional Configuration**
- Initial database name: `myapp`
- Backup retention: **7 days**
- Encryption: **Enabled** (recommended)
- Monitoring: **Enable Enhanced Monitoring**

**7. Review and Create**
- Review settings
- Click **Create database**
- Wait 5-10 minutes for creation

## Step 5: Create RDS Instance (CLI)

### Quick Creation Script

```bash
# Set variables
DB_INSTANCE_ID="my-first-database"
DB_NAME="myapp"
MASTER_USERNAME="admin"
MASTER_PASSWORD="MySecurePass123!"  # Change this!

# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier $DB_INSTANCE_ID \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --engine-version 8.0.35 \
  --master-username $MASTER_USERNAME \
  --master-password "$MASTER_PASSWORD" \
  --allocated-storage 20 \
  --storage-type gp3 \
  --storage-encrypted \
  --db-subnet-group-name my-db-subnet-group \
  --vpc-security-group-ids $DB_SG_ID \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00" \
  --preferred-maintenance-window "mon:04:00-mon:05:00" \
  --db-name $DB_NAME \
  --publicly-accessible \
  --enable-cloudwatch-logs-exports '["error","general","slowquery"]' \
  --tags Key=Name,Value=tutorial-database Key=Environment,Value=development

echo "✅ RDS instance creation initiated"
echo "⏳ This will take 5-10 minutes..."
```

### Wait for Instance to be Available

```bash
# Wait for RDS instance to be ready
aws rds wait db-instance-available \
  --db-instance-identifier $DB_INSTANCE_ID

echo "✅ RDS instance is now available!"

# Get endpoint
DB_ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier $DB_INSTANCE_ID \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

echo "Database Endpoint: $DB_ENDPOINT"
```

## Step 6: Connect to Your Database

### Option 1: MySQL Client (Recommended)

```bash
# Install MySQL client (if not already installed)
# macOS: brew install mysql-client
# Ubuntu/Debian: sudo apt-get install mysql-client
# Amazon Linux: sudo yum install mysql

# Connect to database
mysql -h $DB_ENDPOINT \
  -P 3306 \
  -u admin \
  -p$MASTER_PASSWORD \
  $DB_NAME

# You should see:
# mysql>
```

### Option 2: MySQL Workbench (GUI)

1. Download MySQL Workbench
2. Create new connection:
   - Connection Name: My RDS Database
   - Hostname: `<your-db-endpoint>`
   - Port: 3306
   - Username: admin
   - Password: Store in vault
3. Test Connection
4. Connect!

### Option 3: From EC2 Instance

```bash
# SSH into EC2 instance in same VPC
# Then connect to RDS
mysql -h $DB_ENDPOINT -u admin -p

# Enter password when prompted
```

## Step 7: Create Your First Table

Once connected to MySQL:

```sql
-- Check current database
SELECT DATABASE();

-- Create users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email)
);

-- Verify table creation
SHOW TABLES;

-- Describe table structure
DESCRIBE users;

-- Insert sample data
INSERT INTO users (username, email) VALUES
    ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com'),
    ('charlie', 'charlie@example.com');

-- Query data
SELECT * FROM users;

-- Count users
SELECT COUNT(*) AS total_users FROM users;
```

## Step 8: Monitor Your Database

### Check Instance Status

```bash
# Get instance details
aws rds describe-db-instances \
  --db-instance-identifier $DB_INSTANCE_ID \
  --query 'DBInstances[0].{Status:DBInstanceStatus,Engine:Engine,Class:DBInstanceClass,Storage:AllocatedStorage}' \
  --output table

# Check available metrics
aws cloudwatch list-metrics \
  --namespace AWS/RDS \
  --dimensions Name=DBInstanceIdentifier,Value=$DB_INSTANCE_ID \
  --query 'Metrics[].MetricName' \
  --output table
```

### View CloudWatch Metrics

```bash
# Get CPU utilization (last hour)
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=$DB_INSTANCE_ID \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --query 'Datapoints[].[Timestamp,Average]' \
  --output table

# Get database connections
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=$DB_INSTANCE_ID \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Maximum \
  --output table
```

### Access Logs

```bash
# List available log files
aws rds describe-db-log-files \
  --db-instance-identifier $DB_INSTANCE_ID

# Download error log
aws rds download-db-log-file-portion \
  --db-instance-identifier $DB_INSTANCE_ID \
  --log-file-name error/mysql-error.log \
  --output text
```

## Step 9: Test Performance

### Run Benchmark Queries

```sql
-- Create test table with more data
CREATE TABLE performance_test (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 10,000 rows
DELIMITER $$
CREATE PROCEDURE insert_test_data()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 10000 DO
        INSERT INTO performance_test (data) VALUES (CONCAT('Test data ', i));
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL insert_test_data();

-- Test query performance
SELECT COUNT(*) FROM performance_test WHERE data LIKE '%500%';
```

## Common Issues & Solutions

### Issue 1: Can't Connect to Database

**Symptoms**: Connection timeout or refused

**Solutions**:
```bash
# 1. Check security group rules
aws ec2 describe-security-groups --group-ids $DB_SG_ID \
  --query 'SecurityGroups[0].IpPermissions'

# 2. Verify endpoint
aws rds describe-db-instances \
  --db-instance-identifier $DB_INSTANCE_ID \
  --query 'DBInstances[0].Endpoint'

# 3. Check if instance is available
aws rds describe-db-instances \
  --db-instance-identifier $DB_INSTANCE_ID \
  --query 'DBInstances[0].DBInstanceStatus'

# 4. Test network connectivity
telnet $DB_ENDPOINT 3306
# Or: nc -zv $DB_ENDPOINT 3306
```

### Issue 2: Forgot Master Password

**Solution**: Reset password
```bash
aws rds modify-db-instance \
  --db-instance-identifier $DB_INSTANCE_ID \
  --master-user-password "NewSecurePassword123!" \
  --apply-immediately

# Wait for modification
aws rds wait db-instance-available \
  --db-instance-identifier $DB_INSTANCE_ID
```

### Issue 3: Storage Full

**Solution**: Increase storage
```bash
aws rds modify-db-instance \
  --db-instance-identifier $DB_INSTANCE_ID \
  --allocated-storage 30 \
  --apply-immediately
```

## Step 10: Cleanup (Important!)

**Stop paying for resources you're not using:**

```bash
# Option 1: Delete instance (PERMANENT!)
aws rds delete-db-instance \
  --db-instance-identifier $DB_INSTANCE_ID \
  --skip-final-snapshot

# Option 2: Delete with final snapshot (RECOMMENDED)
aws rds delete-db-instance \
  --db-instance-identifier $DB_INSTANCE_ID \
  --final-db-snapshot-identifier my-first-database-final-snapshot

# Wait for deletion
# aws rds wait db-instance-deleted \
#   --db-instance-identifier $DB_INSTANCE_ID

# Clean up other resources
aws rds delete-db-subnet-group \
  --db-subnet-group-name my-db-subnet-group

aws ec2 delete-security-group \
  --group-id $DB_SG_ID

echo "✅ Cleanup complete!"
```

## Best Practices Checklist

✅ **Security**
- Use strong passwords (20+ characters)
- Enable encryption at rest
- Restrict security group access
- Use IAM database authentication (advanced)
- Enable SSL/TLS connections

✅ **Performance**
- Choose appropriate instance class
- Enable Enhanced Monitoring
- Use Parameter Groups for tuning
- Monitor slow query logs

✅ **Availability**
- Use Multi-AZ for production (next guide!)
- Enable automated backups
- Test restore procedures
- Plan maintenance windows

✅ **Cost**
- Use Free Tier when learning
- Stop/start for dev databases
- Delete unused instances
- Monitor storage growth

## Next Steps

Now that you have a working RDS instance:

1. **[RDS Backups & Snapshots](./rds-backups-snapshots.md)** - Learn data protection
2. **[RDS Multi-AZ](../../intermediate-level/09-database-services/01-rds-advanced/rds-multi-az-read-replicas.md)** - High availability
3. **[RDS Performance](../../intermediate-level/09-database-services/01-rds-advanced/rds-performance-tuning.md)** - Optimization
4. **[DynamoDB Getting Started](../03-dynamodb-basics/dynamodb-getting-started.md)** - Try NoSQL

## Quick Reference

```bash
# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --master-username admin \
  --master-password <password> \
  --allocated-storage 20

# Connect to database
mysql -h <endpoint> -u admin -p

# Modify instance
aws rds modify-db-instance \
  --db-instance-identifier mydb \
  --allocated-storage 40

# Create snapshot
aws rds create-db-snapshot \
  --db-instance-identifier mydb \
  --db-snapshot-identifier mydb-snapshot

# Delete instance
aws rds delete-db-instance \
  --db-instance-identifier mydb \
  --final-db-snapshot-identifier mydb-final
```

## Summary

✅ Created DB subnet group  
✅ Set up security group  
✅ Launched RDS MySQL instance  
✅ Connected to database  
✅ Created tables and inserted data  
✅ Monitored metrics  
✅ Learned troubleshooting  
✅ Cleaned up resources  

**Time Spent**: 20-30 minutes  
**Skills Learned**: RDS fundamentals, database management, AWS CLI

---

**Pro Tip**: Use RDS for production databases - you get automated backups, patching, and high availability without managing servers!

<br>

# 🌟 Real-World Scenarios

### Scenario 1: Connection Timeout Crisis
**Situation**: You just launched an RDS instance for a new startup app, but the application server on EC2 cannot connect. It times out.
**Diagnosis**:
*   The RDS Security Group does not allow inbound traffic on port 3306 from the EC2 instance's Security Group.
*   The RDS instance is in a private subnet, and the EC2 is in a public subnet, but NACLs might be blocking return traffic.
**Solution**:
1.  Check the RDS Security Group Inbound rules. Add a rule allowing Type: MYSQL/Aurora (3306), Source: `sg-xxxxx` (The ID of your WebServer Security Group).
2.  Ensure both are in the same VPC.

### Scenario 2: The "Delete" Mistake
**Situation**: A junior developer accidentally deleted the production RDS instance via the console to "save money" over the weekend. They clicked "No" on "Create final snapshot".
**Impact**: All data is lost permanently.
**Prevention**:
1.  Enable **Deletion Protection** on production instances. This prevents the console/CLI from deleting the DB until the flag is unchecked.
2.  Always enforce "Create Final Snapshot" via organizational policy.

### Scenario 3: Slow Query Troubleshooting
**Situation**: Users report that the login page is taking 10 seconds to load.
**Action**:
1.  Enable **Performance Insights** on the RDS instance.
2.  Check the "Top SQL" queries. You find `SELECT * FROM users WHERE email = '...'` is scanning the whole table.
3.  **Fix**: Add an index on the `email` column: `CREATE INDEX idx_email ON users(email);`.

---

# 🎓 Interview Questions

**Q1: How do you securely connect to an RDS instance in a generic implementation?**
**Answer**:
1.  Place the RDS instance in a Private Subnet (no public IP).
2.  Place the Application Server (EC2) in a Public or Private subnet within the same VPC.
3.  Configure the RDS Security Group to allow inbound traffic on port 3306 ONLY from the Application Server's Security Group ID.
4.  Never open port 3306 to `0.0.0.0/0`.

**Q2: What is the difference between stopping an RDS instance and deleting it?**
**Answer**:
*   **Stopping**: Pauses the instance for up to 7 days. You are not charged for instance hours, but you still pay for storage. It automatically starts after 7 days.
*   **Deleting**: Removes the instance permanently. You stop paying for everything unless you keep a Snapshot (which costs mainly S3 storage rates).

**Q3: How would you design a setup where developers can access a private RDS instance for debugging?**
**Answer**:
Use a **Bastion Host** (Jump Box) or AWS Systems Manager Session Manager.
1.  Launch a small EC2 instance in a public subnet.
2.  Allow SSH (port 22) access to the Bastion Host from the office IP only.
3.  Allow MySQL (port 3306) access to the RDS instance from the Bastion Host's Security Group.
4.  Developers SSH into the Bastion Host (with port forwarding) to connect to RDS.

---

# 🧠 Knowledge Quiz

<b>1. To launch an RDS instance, what is the minimum number of Availability Zones required for the DB Subnet Group?</b>
<details>
<summary>Show Answer</summary>
Answer: B** - A DB Subnet Group must cover at least two Availability Zones to support Multi-AZ deployments.
</details>




<b>2. Which CLI command is used to retrieve the endpoint of your new RDS instance?</b>
<details>
<summary>Show Answer</summary>
Answer: B** - The endpoint is found within the output of the describe-db-instances command.
</details>




<b>3. You are trying to connect to your RDS MySQL instance but get "Access Denied for user 'admin'". What is the most likely cause?</b>
<details>
<summary>Show Answer</summary>
Answer: C** - "Access Denied" implies connectivity is successful (network is fine), but authentication failed.
</details>




<b>4. True or False: Changing the instance type (e.g., from t3.micro to m5.large) causes downtime.</b>
<details>
<summary>Show Answer</summary>
Answer: True** - Scaling compute (vertical scaling) requires a reboot of the instance, causing a short outage (unless using Multi-AZ where it fails over).
</details>




<b>5. What is the default port for MySQL?</b>
<details>
<summary>Show Answer</summary>
Answer: C** - 3306 is the standard port for MySQL and MariaDB.
</details>




<b>6. Which feature allows you to view the exact SQL queries causing high load on your database?</b>
<details>
<summary>Show Answer</summary>
Answer: B** - Performance Insights visualizes database load and filters by SQL statements.
</details>




<b>7. When you delete an RDS instance, what is the best practice to ensure you can restore data later?</b>
<details>
<summary>Show Answer</summary>
Answer: C** - A Final Snapshot captures the state of the database immediately before deletion.
</details>




<b>8. Why is it recommended to use a CNAME (DNS endpoint) instead of an IP address to connect to RDS?</b>
<details>
<summary>Show Answer</summary>
Answer: C** - AWS manages the DNS entries; the IP can change, but the endpoint remains constant.
</details>




<b>9. How many days of automated backups does RDS keep by default if not specified?</b>
<details>
<summary>Show Answer</summary>
Answer: C** - By default (console), it's 7 days. (Note: CLI default might differ, but generally 7 is the standard expectation for production).
</details>




<b>10. Can you stop an RDS instance indefinitely?</b>
<details>
<summary>Show Answer</summary>
Answer: B** - Stopped instances automatically start after 7 days to ensure they don't fall behind on maintenance updates.
</details>




