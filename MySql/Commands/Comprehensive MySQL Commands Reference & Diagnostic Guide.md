## **MySQL Installation & Setup**

### Installation Commands

#### Amazon Linux / RHEL / CentOS

```bash
# Update system
sudo yum update -y

# Install MySQL Server
sudo yum install mysql-server -y

# Install specific version (MySQL 8.4)
sudo yum install mysql-community-server-8.4.* -y

# Install MySQL repository
sudo wget https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm
sudo rpm -ivh mysql84-community-release-el9-1.noarch.rpm
sudo yum install mysql-community-server -y

# Start MySQL service
sudo systemctl start mysqld

# Enable MySQL on boot
sudo systemctl enable mysqld

# Check MySQL status
sudo systemctl status mysqld

# Get temporary root password (first time only)
sudo grep 'temporary password' /var/log/mysqld.log

# Alternative: Extract just the password
sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}'
```

#### Ubuntu / Debian

```bash
# Update system
sudo apt update

# Install MySQL Server
sudo apt install mysql-server -y

# Secure installation
sudo mysql_secure_installation

# Start MySQL service
sudo systemctl start mysql

# Enable MySQL on boot
sudo systemctl enable mysql

# Check status
sudo systemctl status mysql
```

#### Using Docker

```bash
# Run MySQL container
docker run -d \
  --name mysql-petclinic \
  -e MYSQL_ROOT_PASSWORD=petclinic \
  -e MYSQL_DATABASE=petclinic \
  -e MYSQL_USER=petclinic \
  -e MYSQL_PASSWORD=petclinic \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:8.4.5

# With custom configuration
docker run -d \
  --name mysql-petclinic \
  -e MYSQL_ROOT_PASSWORD=petclinic \
  -v /my/custom:/etc/mysql/conf.d \
  -v mysql-data:/var/lib/mysql \
  -p 3306:3306 \
  mysql:8.4.5

# Check logs
docker logs mysql-petclinic

# Connect to container
docker exec -it mysql-petclinic mysql -uroot -p
```

### Initial Configuration

```bash
# Change root password (first time)
mysql -u root -p'TEMPORARY_PASSWORD' --connect-expired-password \
  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'NewPassword123!';"

# Run secure installation
sudo mysql_secure_installation

# Prompts will ask:
# - Set root password: Yes
# - Remove anonymous users: Yes
# - Disallow root login remotely: No (for development) / Yes (for production)
# - Remove test database: Yes
# - Reload privilege tables: Yes
```

---

## **MySQL Connection & Access**

### Connection Commands

```bash
# Connect as root locally
mysql -u root -p

# Connect as root with password (not recommended for production)
mysql -u root -pYourPassword

# Connect to specific host
mysql -h hostname -u username -p

# Connect to specific database
mysql -u username -p database_name

# Connect with specific port
mysql -h hostname -P 3306 -u username -p

# Connect via socket
mysql -u root -p --socket=/var/lib/mysql/mysql.sock

# Connect with SSL
mysql -h hostname -u username -p --ssl-mode=REQUIRED

# Execute command without entering interactive mode
mysql -u root -p -e "SHOW DATABASES;"

# Execute commands from file
mysql -u root -p < script.sql

# Execute with output to file
mysql -u root -p -e "SELECT * FROM users;" > output.txt

# Connect and execute multiple commands
mysql -u root -p <<EOF
USE mydb;
SHOW TABLES;
SELECT COUNT(*) FROM users;
EOF

# Batch mode (no table formatting)
mysql -u root -p -B -e "SELECT * FROM users;"

# HTML output
mysql -u root -p -H -e "SELECT * FROM users;" > output.html

# XML output
mysql -u root -p -X -e "SELECT * FROM users;" > output.xml

# Vertical output (\G format)
mysql -u root -p -e "SHOW PROCESSLIST\G"
```

### MySQL Client Options

```bash
# Verbose mode
mysql -u root -p -v

# Show warnings
mysql -u root -p --show-warnings

# Force continue on error
mysql -u root -p --force

# Reconnect automatically
mysql -u root -p --reconnect

# Compress client/server protocol
mysql -h remote_host -u username -p --compress

# Set character set
mysql -u root -p --default-character-set=utf8mb4

# Debug mode
mysql -u root -p --debug

# Print defaults
mysql --print-defaults
```

---

## **Database Management**

### Database Operations

```sql
-- List all databases
SHOW DATABASES;

-- Create database
CREATE DATABASE database_name;

-- Create database with character set
CREATE DATABASE database_name 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS database_name;

-- Select/Use database
USE database_name;

-- Show current database
SELECT DATABASE();

-- Drop database
DROP DATABASE database_name;

-- Drop if exists
DROP DATABASE IF EXISTS database_name;

-- Get database size
SELECT 
  table_schema AS 'Database',
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
GROUP BY table_schema;

-- Get specific database size
SELECT 
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'database_name';

-- Show database creation statement
SHOW CREATE DATABASE database_name;

-- Alter database character set
ALTER DATABASE database_name 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;
```

### Spring Petclinic Database Setup

```sql
-- Create databases for microservices
CREATE DATABASE IF NOT EXISTS petclinic_customers 
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS petclinic_visits 
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS petclinic_vets 
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Verify databases
SHOW DATABASES LIKE 'petclinic%';

-- Show database sizes
SELECT 
  table_schema AS 'Database',
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema LIKE 'petclinic%'
GROUP BY table_schema;
```

---

## **Table Management**

### Table Operations

```sql
-- List tables in current database
SHOW TABLES;

-- List tables in specific database
SHOW TABLES FROM database_name;

-- List tables with pattern
SHOW TABLES LIKE 'user%';

-- Describe table structure
DESCRIBE table_name;
DESC table_name;

-- Show table creation statement
SHOW CREATE TABLE table_name;

-- Show table status
SHOW TABLE STATUS;
SHOW TABLE STATUS LIKE 'users';

-- Get detailed table information
SELECT * FROM information_schema.TABLES 
WHERE table_schema = 'database_name' 
  AND table_name = 'table_name';

-- Show columns
SHOW COLUMNS FROM table_name;

-- Show indexes
SHOW INDEXES FROM table_name;

-- Show table size
SELECT 
  table_name AS 'Table',
  ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'database_name'
ORDER BY (data_length + index_length) DESC;
```

### Create Table Examples

```sql
-- Create owners table (Petclinic)
CREATE TABLE owners (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  address VARCHAR(255),
  city VARCHAR(80),
  telephone VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_last_name (last_name),
  INDEX idx_city (city)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create pets table
CREATE TABLE pets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  birth_date DATE,
  type_id INT NOT NULL,
  owner_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_name (name),
  INDEX idx_owner_id (owner_id),
  FOREIGN KEY (owner_id) REFERENCES owners(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create visits table
CREATE TABLE visits (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pet_id INT NOT NULL,
  visit_date DATE NOT NULL,
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_pet_id (pet_id),
  INDEX idx_visit_date (visit_date),
  FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create vets table
CREATE TABLE vets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_last_name (last_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Alter Table Operations

```sql
-- Add column
ALTER TABLE table_name ADD column_name VARCHAR(255);

-- Add column with position
ALTER TABLE table_name ADD column_name VARCHAR(255) AFTER existing_column;
ALTER TABLE table_name ADD column_name VARCHAR(255) FIRST;

-- Modify column
ALTER TABLE table_name MODIFY column_name VARCHAR(100);

-- Change column name and definition
ALTER TABLE table_name CHANGE old_name new_name VARCHAR(255);

-- Drop column
ALTER TABLE table_name DROP COLUMN column_name;

-- Add index
ALTER TABLE table_name ADD INDEX idx_name (column_name);

-- Add unique index
ALTER TABLE table_name ADD UNIQUE KEY uk_name (column_name);

-- Add primary key
ALTER TABLE table_name ADD PRIMARY KEY (id);

-- Drop index
ALTER TABLE table_name DROP INDEX idx_name;

-- Add foreign key
ALTER TABLE table_name 
  ADD CONSTRAINT fk_name 
  FOREIGN KEY (column_name) 
  REFERENCES other_table(id) 
  ON DELETE CASCADE;

-- Drop foreign key
ALTER TABLE table_name DROP FOREIGN KEY fk_name;

-- Rename table
ALTER TABLE old_name RENAME TO new_name;
RENAME TABLE old_name TO new_name;

-- Change engine
ALTER TABLE table_name ENGINE=InnoDB;

-- Change character set
ALTER TABLE table_name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Drop Table Operations

```sql
-- Drop table
DROP TABLE table_name;

-- Drop if exists
DROP TABLE IF EXISTS table_name;

-- Drop multiple tables
DROP TABLE table1, table2, table3;

-- Truncate table (faster than DELETE)
TRUNCATE TABLE table_name;
```

---

## **User Management**

### User Operations

```sql
-- List all users
SELECT user, host FROM mysql.user;

-- Show current user
SELECT USER(), CURRENT_USER();

-- Create user
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';

-- Create user for remote access
CREATE USER 'username'@'%' IDENTIFIED BY 'password';

-- Create user with specific host
CREATE USER 'username'@'10.0.1.%' IDENTIFIED BY 'password';

-- Create user if not exists
CREATE USER IF NOT EXISTS 'username'@'localhost' IDENTIFIED BY 'password';

-- Create user with authentication plugin
CREATE USER 'username'@'localhost' 
  IDENTIFIED WITH mysql_native_password BY 'password';

-- Create Petclinic user
CREATE USER 'petclinic'@'%' IDENTIFIED BY 'petclinic';

-- Change user password
ALTER USER 'username'@'localhost' IDENTIFIED BY 'new_password';

-- Change root password
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';

-- Set password expiration
ALTER USER 'username'@'localhost' PASSWORD EXPIRE;

-- Set password to never expire
ALTER USER 'username'@'localhost' PASSWORD EXPIRE NEVER;

-- Rename user
RENAME USER 'old_username'@'localhost' TO 'new_username'@'localhost';

-- Drop user
DROP USER 'username'@'localhost';

-- Drop if exists
DROP USER IF EXISTS 'username'@'localhost';

-- Lock user account
ALTER USER 'username'@'localhost' ACCOUNT LOCK;

-- Unlock user account
ALTER USER 'username'@'localhost' ACCOUNT UNLOCK;
```

### Privilege Management

```sql
-- Grant all privileges on database
GRANT ALL PRIVILEGES ON database_name.* TO 'username'@'localhost';

-- Grant all privileges on all databases
GRANT ALL PRIVILEGES ON *.* TO 'username'@'localhost';

-- Grant specific privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON database_name.* TO 'username'@'localhost';

-- Grant with grant option (can grant to others)
GRANT ALL PRIVILEGES ON database_name.* TO 'username'@'localhost' WITH GRANT OPTION;

-- Grant on specific table
GRANT SELECT, UPDATE ON database_name.table_name TO 'username'@'localhost';

-- Grant privileges for Petclinic user
GRANT ALL PRIVILEGES ON petclinic_customers.* TO 'petclinic'@'%';
GRANT ALL PRIVILEGES ON petclinic_visits.* TO 'petclinic'@'%';
GRANT ALL PRIVILEGES ON petclinic_vets.* TO 'petclinic'@'%';

-- Show grants for user
SHOW GRANTS FOR 'username'@'localhost';

-- Show current user grants
SHOW GRANTS;
SHOW GRANTS FOR CURRENT_USER();

-- Revoke privileges
REVOKE ALL PRIVILEGES ON database_name.* FROM 'username'@'localhost';

-- Revoke specific privileges
REVOKE INSERT, UPDATE ON database_name.* FROM 'username'@'localhost';

-- Flush privileges (apply changes immediately)
FLUSH PRIVILEGES;

-- Check specific privilege
SELECT * FROM mysql.user WHERE user='username'\G
SELECT * FROM mysql.db WHERE user='username'\G
```

---

## **Data Manipulation (CRUD)**

### SELECT Queries

```sql
-- Basic select
SELECT * FROM table_name;

-- Select specific columns
SELECT column1, column2 FROM table_name;

-- Select with WHERE clause
SELECT * FROM owners WHERE city = 'Madison';

-- Select with multiple conditions
SELECT * FROM owners 
WHERE city = 'Madison' AND last_name LIKE 'F%';

-- Select with OR
SELECT * FROM owners 
WHERE city = 'Madison' OR city = 'Monona';

-- Select with IN
SELECT * FROM owners 
WHERE city IN ('Madison', 'Monona', 'Sun Prairie');

-- Select with BETWEEN
SELECT * FROM pets 
WHERE birth_date BETWEEN '2020-01-01' AND '2023-12-31';

-- Select with IS NULL
SELECT * FROM owners WHERE telephone IS NULL;

-- Select with IS NOT NULL
SELECT * FROM owners WHERE telephone IS NOT NULL;

-- Select with LIKE (pattern matching)
SELECT * FROM owners WHERE last_name LIKE 'F%';
SELECT * FROM owners WHERE first_name LIKE '%son';
SELECT * FROM owners WHERE address LIKE '%Main%';

-- Select with ORDER BY
SELECT * FROM owners ORDER BY last_name ASC;
SELECT * FROM owners ORDER BY city DESC, last_name ASC;

-- Select with LIMIT
SELECT * FROM owners LIMIT 10;

-- Select with LIMIT and OFFSET
SELECT * FROM owners LIMIT 10 OFFSET 20;

-- Select with aggregation
SELECT COUNT(*) FROM owners;
SELECT COUNT(*) FROM owners WHERE city = 'Madison';
SELECT city, COUNT(*) as count FROM owners GROUP BY city;

-- Select with JOIN
SELECT 
  o.first_name, 
  o.last_name, 
  p.name as pet_name, 
  p.birth_date
FROM owners o
JOIN pets p ON o.id = p.owner_id;

-- LEFT JOIN
SELECT 
  o.first_name, 
  o.last_name, 
  COUNT(p.id) as pet_count
FROM owners o
LEFT JOIN pets p ON o.id = p.owner_id
GROUP BY o.id;

-- Multiple JOINs
SELECT 
  o.first_name,
  o.last_name,
  p.name as pet_name,
  v.visit_date,
  v.description
FROM owners o
JOIN pets p ON o.id = p.owner_id
JOIN visits v ON p.id = v.pet_id
ORDER BY v.visit_date DESC;

-- Subquery
SELECT * FROM owners 
WHERE id IN (SELECT owner_id FROM pets WHERE name = 'Max');

-- DISTINCT
SELECT DISTINCT city FROM owners;

-- GROUP BY with HAVING
SELECT city, COUNT(*) as count 
FROM owners 
GROUP BY city 
HAVING count > 5;
```

### INSERT Operations

```sql
-- Insert single row
INSERT INTO owners (first_name, last_name, city, telephone)
VALUES ('John', 'Doe', 'Madison', '608-555-1234');

-- Insert multiple rows
INSERT INTO owners (first_name, last_name, city, telephone)
VALUES 
  ('Jane', 'Smith', 'Monona', '608-555-2345'),
  ('Bob', 'Johnson', 'Sun Prairie', '608-555-3456'),
  ('Alice', 'Williams', 'Madison', '608-555-4567');

-- Insert with specific columns
INSERT INTO owners (first_name, last_name)
VALUES ('Mike', 'Brown');

-- Insert and get last inserted ID
INSERT INTO owners (first_name, last_name, city)
VALUES ('Sarah', 'Davis', 'Madison');
SELECT LAST_INSERT_ID();

-- Insert from SELECT
INSERT INTO owners_backup 
SELECT * FROM owners WHERE city = 'Madison';

-- Insert on duplicate key update
INSERT INTO owners (id, first_name, last_name, city)
VALUES (1, 'John', 'Doe', 'Madison')
ON DUPLICATE KEY UPDATE 
  first_name = VALUES(first_name),
  last_name = VALUES(last_name),
  city = VALUES(city);

-- Insert ignore (skip duplicates)
INSERT IGNORE INTO owners (id, first_name, last_name)
VALUES (1, 'John', 'Doe');
```

### UPDATE Operations

```sql
-- Update single row
UPDATE owners SET telephone = '608-555-9999' WHERE id = 1;

-- Update multiple columns
UPDATE owners 
SET first_name = 'Jonathan', telephone = '608-555-8888' 
WHERE id = 1;

-- Update with calculation
UPDATE owners 
SET city = UPPER(city);

-- Update with JOIN
UPDATE owners o
JOIN pets p ON o.id = p.owner_id
SET o.telephone = '608-555-0000'
WHERE p.name = 'Max';

-- Update all rows (be careful!)
UPDATE owners SET city = 'Madison';

-- Update with LIMIT
UPDATE owners SET city = 'Madison' LIMIT 10;

-- Update with CASE
UPDATE owners
SET city = CASE
  WHEN city = 'Mad' THEN 'Madison'
  WHEN city = 'Mon' THEN 'Monona'
  ELSE city
END;
```

### DELETE Operations

```sql
-- Delete specific row
DELETE FROM owners WHERE id = 1;

-- Delete with condition
DELETE FROM owners WHERE city = 'Madison';

-- Delete with multiple conditions
DELETE FROM owners 
WHERE city = 'Madison' AND telephone IS NULL;

-- Delete with LIMIT
DELETE FROM owners WHERE city = 'Madison' LIMIT 10;

-- Delete with JOIN
DELETE o FROM owners o
LEFT JOIN pets p ON o.id = p.owner_id
WHERE p.id IS NULL;

-- Delete all rows (be careful!)
DELETE FROM owners;

-- Truncate (faster, resets auto-increment)
TRUNCATE TABLE owners;
```

---

## **Backup & Restore**

### Backup Operations

```bash
# Backup single database
mysqldump -u root -p database_name > backup.sql

# Backup multiple databases
mysqldump -u root -p --databases db1 db2 db3 > backup.sql

# Backup all databases
mysqldump -u root -p --all-databases > all_databases.sql

# Backup specific table
mysqldump -u root -p database_name table_name > table_backup.sql

# Backup with compression
mysqldump -u root -p database_name | gzip > backup.sql.gz

# Backup structure only (no data)
mysqldump -u root -p --no-data database_name > structure.sql

# Backup data only (no structure)
mysqldump -u root -p --no-create-info database_name > data.sql

# Backup with routines and triggers
mysqldump -u root -p --routines --triggers database_name > backup.sql

# Backup Petclinic databases
mysqldump -u root -p petclinic_customers > petclinic_customers_backup.sql
mysqldump -u root -p petclinic_visits > petclinic_visits_backup.sql
mysqldump -u root -p petclinic_vets > petclinic_vets_backup.sql

# Backup all Petclinic databases
mysqldump -u root -p --databases petclinic_customers petclinic_visits petclinic_vets > petclinic_full_backup.sql

# Backup with timestamp
mysqldump -u root -p database_name > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup to remote server
mysqldump -u root -p database_name | ssh user@remote_host "cat > /backup/database.sql"

# Backup with single transaction (InnoDB)
mysqldump -u root -p --single-transaction database_name > backup.sql

# Backup excluding specific tables
mysqldump -u root -p database_name --ignore-table=database_name.table1 --ignore-table=database_name.table2 > backup.sql
```

### Restore Operations

```bash
# Restore database
mysql -u root -p database_name < backup.sql

# Restore all databases
mysql -u root -p < all_databases.sql

# Restore from compressed backup
gunzip < backup.sql.gz | mysql -u root -p database_name

# Restore with progress
pv backup.sql | mysql -u root -p database_name

# Restore specific table
mysql -u root -p database_name < table_backup.sql

# Restore Petclinic databases
mysql -u root -p petclinic_customers < petclinic_customers_backup.sql
mysql -u root -p petclinic_visits < petclinic_visits_backup.sql
mysql -u root -p petclinic_vets < petclinic_vets_backup.sql

# Create database and restore
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS database_name;"
mysql -u root -p database_name < backup.sql

# Restore with error logging
mysql -u root -p database_name < backup.sql 2> restore_errors.log
```

### Binary Log Backup (Point-in-Time Recovery)

```bash
# Flush logs
mysql -u root -p -e "FLUSH LOGS;"

# Backup binary logs
cp /var/lib/mysql/mysql-bin.* /backup/binlogs/

# Show binary logs
mysql -u root -p -e "SHOW BINARY LOGS;"

# Show master status
mysql -u root -p -e "SHOW MASTER STATUS\G"

# Restore from binary log
mysqlbinlog /var/lib/mysql/mysql-bin.000001 | mysql -u root -p

# Restore from specific position
mysqlbinlog --start-position=154 /var/lib/mysql/mysql-bin.000001 | mysql -u root -p

# Restore from specific datetime
mysqlbinlog --start-datetime="2025-01-01 10:00:00" /var/lib/mysql/mysql-bin.000001 | mysql -u root -p
```

---

## **Performance & Monitoring**

### System Status

```sql
-- Show server status
SHOW STATUS;

-- Show specific status variable
SHOW STATUS LIKE 'Threads%';
SHOW STATUS LIKE 'Connections';
SHOW STATUS LIKE 'Uptime';

-- Show global variables
SHOW VARIABLES;

-- Show specific variable
SHOW VARIABLES LIKE 'max_connections';
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';

-- Show processlist (active connections)
SHOW PROCESSLIST;
SHOW FULL PROCESSLIST;

-- Kill specific process
KILL PROCESS_ID;

-- Show engine status
SHOW ENGINE INNODB STATUS\G

-- Show table status
SHOW TABLE STATUS FROM database_name;

-- Show open tables
SHOW OPEN TABLES FROM database_name;

-- Show indexes
SHOW INDEX FROM table_name;

-- Check table optimization
ANALYZE TABLE table_name;
OPTIMIZE TABLE table_name;
CHECK TABLE table_name;
REPAIR TABLE table_name;
```

### Performance Queries

```sql
-- Show slow queries
SHOW VARIABLES LIKE 'slow_query%';
SHOW STATUS LIKE 'Slow_queries';

-- Find longest running queries
SELECT * FROM information_schema.PROCESSLIST 
WHERE TIME > 10 
ORDER BY TIME DESC;

-- Show database sizes
SELECT 
  table_schema AS 'Database',
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
GROUP BY table_schema
ORDER BY SUM(data_length + index_length) DESC;

-- Show table sizes
SELECT 
  table_name AS 'Table',
  ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)',
  table_rows AS 'Rows'
FROM information_schema.TABLES
WHERE table_schema = 'database_name'
ORDER BY (data_length + index_length) DESC;

-- Show fragmented tables
SELECT 
  table_name,
  ROUND(data_length / 1024 / 1024, 2) AS 'Data (MB)',
  ROUND(data_free / 1024 / 1024, 2) AS 'Free (MB)',
  ROUND(data_free / (data_length + data_free) * 100, 2) AS 'Fragmentation %'
FROM information_schema.TABLES
WHERE table_schema = 'database_name'
  AND data_free > 0
ORDER BY data_free DESC;

-- Show index usage
SELECT 
  table_schema,
  table_name,
  index_name,
  cardinality
FROM information_schema.STATISTICS
WHERE table_schema = 'database_name'
ORDER BY cardinality DESC;

-- Show unused indexes
SELECT 
  t.table_schema,
  t.table_name,
  s.index_name
FROM information_schema.TABLES t
LEFT JOIN information_schema.STATISTICS s ON t.table_schema = s.table_schema 
  AND t.table_name = s.table_name
WHERE t.table_schema = 'database_name'
  AND s.index_name IS NOT NULL
  AND s.index_name != 'PRIMARY';
```

### Connection Management

```sql
-- Show max connections
SHOW VARIABLES LIKE 'max_connections';

-- Show current connections
SHOW STATUS LIKE 'Threads_connected';

-- Show connection errors
SHOW STATUS LIKE 'Connection_errors%';

-- Show all user connections
SELECT 
  user,
  host,
  db,
  command,
  time,
  state,
  info
FROM information_schema.PROCESSLIST
ORDER BY time DESC;

-- Count connections per user
SELECT 
  user,
  COUNT(*) as connections
FROM information_schema.PROCESSLIST
GROUP BY user
ORDER BY connections DESC;

-- Kill all connections for specific user
SELECT 
  CONCAT('KILL ', id, ';') AS kill_command
FROM information_schema.PROCESSLIST
WHERE user = 'username';
```

---

## **Diagnostic & Troubleshooting Commands**

### Check MySQL Service

```bash
# Check if MySQL is running
sudo systemctl status mysqld
sudo systemctl status mysql

# Check MySQL process
ps aux | grep mysql

# Check MySQL port
sudo netstat -tulpn | grep 3306
sudo ss -tulpn | grep 3306

# Check if MySQL is listening
telnet localhost 3306
nc -zv localhost 3306

# Check MySQL error log
sudo tail -f /var/log/mysqld.log
sudo tail -f /var/log/mysql/error.log

# Check MySQL slow query log
sudo tail -f /var/log/mysql/slow.log

# Check MySQL general log
sudo tail -f /var/log/mysql/general.log
```

### Configuration Files

```bash
# Find MySQL configuration file
mysql --help | grep "Default options" -A 1

# Common locations:
# /etc/my.cnf
# /etc/mysql/my.cnf
# /usr/etc/my.cnf
# ~/.my.cnf

# View configuration
cat /etc/my.cnf

# Edit configuration
sudo vi /etc/my.cnf

# Test configuration
mysqld --validate-config

# Show configuration variables
mysql -u root -p -e "SHOW VARIABLES;"
```

### Network Diagnostics

```bash
# Test connection from remote host
mysql -h <mysql_server_ip> -u petclinic -p

# Test with telnet
telnet <mysql_server_ip> 3306

# Test with nc
nc -zv <mysql_server_ip> 3306

# Check firewall rules (Amazon Linux/RHEL)
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-service=mysql
sudo firewall-cmd --reload

# Check iptables
sudo iptables -L -n | grep 3306

# Check bind address
mysql -u root -p -e "SHOW VARIABLES LIKE 'bind_address';"

# Check for blocked IPs
mysql -u root -p -e "SELECT * FROM performance_schema.host_cache;"

# Flush host cache
mysql -u root -p -e "FLUSH HOSTS;"
```

### Query Debugging

```sql
-- Explain query execution plan
EXPLAIN SELECT * FROM owners WHERE city = 'Madison';

-- Extended explain
EXPLAIN EXTENDED SELECT * FROM owners WHERE city = 'Madison';
SHOW WARNINGS;

-- Analyze query
EXPLAIN ANALYZE SELECT * FROM owners WHERE city = 'Madison';

-- Show query profile
SET profiling = 1;
SELECT * FROM owners WHERE city = 'Madison';
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;

-- Check query cache
SHOW VARIABLES LIKE 'query_cache%';
SHOW STATUS LIKE 'Qcache%';

-- Check index usage
SHOW STATUS LIKE 'Handler_read%';
```

### Lock Diagnostics

```sql
-- Show locked tables
SHOW OPEN TABLES WHERE In_use > 0;

-- Show InnoDB locks
SELECT * FROM information_schema.INNODB_LOCKS;

-- Show lock waits
SELECT
```