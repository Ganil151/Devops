# Database Management

Comprehensive guide to database administration, configuration, and management for DevOps environments.

## Database Technologies

### Supported Databases
- **MySQL/MariaDB**: Open-source relational database
- **PostgreSQL**: Advanced open-source relational database
- **MongoDB**: Document-oriented NoSQL database
- **Redis**: In-memory data structure store
- **Oracle**: Enterprise relational database
- **SQL Server**: Microsoft relational database

### Database Selection Criteria
```yaml
selection_factors:
  performance: "Read/write throughput requirements"
  scalability: "Horizontal vs vertical scaling needs"
  consistency: "ACID compliance requirements"
  availability: "Uptime and disaster recovery needs"
  cost: "Licensing and operational costs"
  expertise: "Team knowledge and support"
```

## Directory Structure

```bash
Databases/
├── MySQL/                    # MySQL administration
│   ├── Installation/         # Setup and configuration
│   ├── Commands/            # SQL commands and queries
│   ├── Performance/         # Optimization and tuning
│   ├── Backup-Restore/      # Data protection
│   └── Security/           # Access control and hardening
├── PostgreSQL/              # PostgreSQL administration
├── MongoDB/                 # MongoDB administration
├── Redis/                   # Redis administration
├── Monitoring/              # Database monitoring
├── Automation/              # Automated management
├── Migration/               # Database migrations
└── Best-Practices/          # General guidelines
```

## Quick Start

### MySQL Setup
```bash
# Install MySQL
sudo yum install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Get temporary password
sudo grep 'temporary password' /var/log/mysqld.log

# Secure installation
sudo mysql_secure_installation
```

### PostgreSQL Setup
```bash
# Install PostgreSQL
sudo yum install postgresql-server -y
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### MongoDB Setup
```bash
# Install MongoDB
sudo yum install mongodb-org -y
sudo systemctl start mongod
sudo systemctl enable mongod
```

## Common Operations

### Database Creation
```sql
-- MySQL
CREATE DATABASE petclinic CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- PostgreSQL
CREATE DATABASE petclinic ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8';
```

### User Management
```sql
-- MySQL
CREATE USER 'petclinic'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON petclinic.* TO 'petclinic'@'%';

-- PostgreSQL
CREATE USER petclinic WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE petclinic TO petclinic;
```

### Backup Operations
```bash
# MySQL
mysqldump -u root -p petclinic > backup.sql

# PostgreSQL
pg_dump -U postgres petclinic > backup.sql

# MongoDB
mongodump --db petclinic --out /backup/
```

## Performance Monitoring

### Key Metrics
- **Connection Count**: Active database connections
- **Query Performance**: Slow query identification
- **Resource Usage**: CPU, memory, disk I/O
- **Lock Contention**: Blocking and deadlocks
- **Replication Lag**: Master-slave synchronization

### Monitoring Tools
- **MySQL**: Performance Schema, sys schema
- **PostgreSQL**: pg_stat views, pg_stat_statements
- **MongoDB**: db.stats(), mongostat
- **External**: Prometheus, Grafana, DataDog

## Security Best Practices

### Access Control
- Use principle of least privilege
- Implement role-based access control
- Regular password rotation
- Network access restrictions

### Data Protection
- Encrypt data at rest and in transit
- Regular security updates
- Audit logging and monitoring
- Backup encryption

## Automation and DevOps

### Infrastructure as Code
- Database provisioning with Terraform
- Configuration management with Ansible
- Container orchestration with Kubernetes
- CI/CD pipeline integration

### Monitoring and Alerting
- Automated health checks
- Performance threshold alerts
- Backup verification
- Disaster recovery testing

This comprehensive database guide provides enterprise-ready patterns for database administration and DevOps integration.