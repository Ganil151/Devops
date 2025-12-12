# Database Setup Examples

Comprehensive Ansible examples for database installation, configuration, and management across different database systems.

## MySQL/MariaDB Setup

### Basic MySQL Installation and Configuration

```yaml
# playbooks/mysql-setup.yml
---
- name: Install and configure MySQL server
  hosts: databases
  become: yes
  vars:
    mysql_root_password: "{{ vault_mysql_root_password }}"
    mysql_databases:
      - name: petclinic_customers
        encoding: utf8mb4
        collation: utf8mb4_unicode_ci
      - name: petclinic_visits
        encoding: utf8mb4
        collation: utf8mb4_unicode_ci
      - name: petclinic_vets
        encoding: utf8mb4
        collation: utf8mb4_unicode_ci
    
    mysql_users:
      - name: petclinic
        password: "{{ vault_petclinic_password }}"
        priv: "petclinic_*.*:ALL"
        host: "%"
      - name: app_readonly
        password: "{{ vault_readonly_password }}"
        priv: "petclinic_*.*:SELECT"
        host: "192.168.1.%"
  
  tasks:
    - name: Install MySQL server packages
      package:
        name:
          - mysql-server
          - python3-pymysql
        state: present
    
    - name: Start and enable MySQL service
      service:
        name: mysqld
        state: started
        enabled: yes
    
    - name: Get temporary root password (first time setup)
      shell: "grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}'"
      register: temp_password
      failed_when: false
      changed_when: false
    
    - name: Set MySQL root password (first time)
      shell: |
        mysql -u root -p'{{ temp_password.stdout }}' --connect-expired-password \
        -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '{{ mysql_root_password }}';"
      when: temp_password.stdout != ""
      ignore_errors: yes
    
    - name: Copy MySQL configuration file
      template:
        src: my.cnf.j2
        dest: /etc/my.cnf
        owner: root
        group: root
        mode: '0644'
      notify: restart mysql
    
    - name: Create MySQL databases
      mysql_db:
        name: "{{ item.name }}"
        encoding: "{{ item.encoding }}"
        collation: "{{ item.collation }}"
        state: present
        login_user: root
        login_password: "{{ mysql_root_password }}"
      loop: "{{ mysql_databases }}"
    
    - name: Create MySQL users
      mysql_user:
        name: "{{ item.name }}"
        password: "{{ item.password }}"
        priv: "{{ item.priv }}"
        host: "{{ item.host }}"
        state: present
        login_user: root
        login_password: "{{ mysql_root_password }}"
      loop: "{{ mysql_users }}"
    
    - name: Remove anonymous MySQL users
      mysql_user:
        name: ""
        host_all: yes
        state: absent
        login_user: root
        login_password: "{{ mysql_root_password }}"
    
    - name: Remove test database
      mysql_db:
        name: test
        state: absent
        login_user: root
        login_password: "{{ mysql_root_password }}"
    
    - name: Configure firewall for MySQL
      firewalld:
        port: 3306/tcp
        permanent: yes
        state: enabled
        immediate: yes
      when: ansible_os_family == "RedHat"
  
  handlers:
    - name: restart mysql
      service:
        name: mysqld
        state: restarted
```

### MySQL Configuration Template

```jinja2
# templates/my.cnf.j2
[mysqld]
# Basic settings
bind-address = {{ mysql_bind_address | default('0.0.0.0') }}
port = {{ mysql_port | default('3306') }}
datadir = {{ mysql_datadir | default('/var/lib/mysql') }}
socket = {{ mysql_socket | default('/var/lib/mysql/mysql.sock') }}

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Connection settings
max_connections = {{ mysql_max_connections | default('200') }}
max_connect_errors = {{ mysql_max_connect_errors | default('10000') }}
wait_timeout = {{ mysql_wait_timeout | default('28800') }}
interactive_timeout = {{ mysql_interactive_timeout | default('28800') }}

# Buffer settings
innodb_buffer_pool_size = {{ mysql_innodb_buffer_pool_size | default('128M') }}
innodb_log_file_size = {{ mysql_innodb_log_file_size | default('64M') }}
innodb_flush_log_at_trx_commit = {{ mysql_innodb_flush_log_at_trx_commit | default('2') }}

# Logging
log_error = {{ mysql_log_error | default('/var/log/mysql/error.log') }}
slow_query_log = {{ mysql_slow_query_log | default('1') }}
slow_query_log_file = {{ mysql_slow_query_log_file | default('/var/log/mysql/slow.log') }}
long_query_time = {{ mysql_long_query_time | default('2') }}

# Security
local_infile = 0
skip_name_resolve = 1

[mysql]
default-character-set = utf8mb4

[client]
default-character-set = utf8mb4
```

### Spring Petclinic Database Schema Setup

```yaml
# playbooks/petclinic-schema.yml
---
- name: Setup Spring Petclinic database schemas
  hosts: databases
  become: yes
  vars:
    mysql_root_password: "{{ vault_mysql_root_password }}"
    schema_files:
      - { db: "petclinic_customers", schema: "customers-schema.sql", data: "customers-data.sql" }
      - { db: "petclinic_visits", schema: "visits-schema.sql", data: "visits-data.sql" }
      - { db: "petclinic_vets", schema: "vets-schema.sql", data: "vets-data.sql" }
  
  tasks:
    - name: Create schema directory
      file:
        path: /tmp/petclinic-schemas
        state: directory
        mode: '0755'
    
    - name: Copy schema files
      copy:
        src: "{{ item.schema }}"
        dest: "/tmp/petclinic-schemas/{{ item.schema }}"
        mode: '0644'
      loop: "{{ schema_files }}"
    
    - name: Copy data files
      copy:
        src: "{{ item.data }}"
        dest: "/tmp/petclinic-schemas/{{ item.data }}"
        mode: '0644'
      loop: "{{ schema_files }}"
    
    - name: Import database schemas
      mysql_db:
        name: "{{ item.db }}"
        state: import
        target: "/tmp/petclinic-schemas/{{ item.schema }}"
        login_user: root
        login_password: "{{ mysql_root_password }}"
      loop: "{{ schema_files }}"
    
    - name: Import sample data
      mysql_db:
        name: "{{ item.db }}"
        state: import
        target: "/tmp/petclinic-schemas/{{ item.data }}"
        login_user: root
        login_password: "{{ mysql_root_password }}"
      loop: "{{ schema_files }}"
    
    - name: Verify database setup
      mysql_query:
        login_user: root
        login_password: "{{ mysql_root_password }}"
        login_db: "{{ item.db }}"
        query: "SHOW TABLES"
      register: table_results
      loop: "{{ schema_files }}"
    
    - name: Display database tables
      debug:
        msg: "Database {{ item.item.db }} contains tables: {{ item.query_result }}"
      loop: "{{ table_results.results }}"
```

## PostgreSQL Setup

### PostgreSQL Installation and Configuration

```yaml
# playbooks/postgresql-setup.yml
---
- name: Install and configure PostgreSQL
  hosts: databases
  become: yes
  vars:
    postgresql_version: "13"
    postgresql_databases:
      - name: petclinic
        owner: petclinic_user
        encoding: UTF8
        locale: en_US.UTF-8
      - name: analytics
        owner: analytics_user
        encoding: UTF8
        locale: en_US.UTF-8
    
    postgresql_users:
      - name: petclinic_user
        password: "{{ vault_petclinic_password }}"
        db: petclinic
        priv: ALL
      - name: analytics_user
        password: "{{ vault_analytics_password }}"
        db: analytics
        priv: ALL
      - name: readonly_user
        password: "{{ vault_readonly_password }}"
        db: petclinic
        priv: SELECT
  
  tasks:
    - name: Install PostgreSQL packages
      package:
        name:
          - "postgresql{{ postgresql_version }}-server"
          - "postgresql{{ postgresql_version }}"
          - python3-psycopg2
        state: present
    
    - name: Check if PostgreSQL is initialized
      stat:
        path: "/var/lib/pgsql/{{ postgresql_version }}/data/postgresql.conf"
      register: postgres_initialized
    
    - name: Initialize PostgreSQL database
      command: "/usr/pgsql-{{ postgresql_version }}/bin/postgresql-{{ postgresql_version }}-setup initdb"
      when: not postgres_initialized.stat.exists
    
    - name: Start and enable PostgreSQL service
      service:
        name: "postgresql-{{ postgresql_version }}"
        state: started
        enabled: yes
    
    - name: Configure PostgreSQL
      template:
        src: "{{ item.src }}"
        dest: "/var/lib/pgsql/{{ postgresql_version }}/data/{{ item.dest }}"
        owner: postgres
        group: postgres
        mode: '0600'
      loop:
        - { src: "postgresql.conf.j2", dest: "postgresql.conf" }
        - { src: "pg_hba.conf.j2", dest: "pg_hba.conf" }
      notify: restart postgresql
    
    - name: Create PostgreSQL databases
      postgresql_db:
        name: "{{ item.name }}"
        owner: "{{ item.owner }}"
        encoding: "{{ item.encoding }}"
        lc_collate: "{{ item.locale }}"
        lc_ctype: "{{ item.locale }}"
        state: present
      become_user: postgres
      loop: "{{ postgresql_databases }}"
    
    - name: Create PostgreSQL users
      postgresql_user:
        name: "{{ item.name }}"
        password: "{{ item.password }}"
        db: "{{ item.db }}"
        priv: "{{ item.priv }}"
        state: present
      become_user: postgres
      loop: "{{ postgresql_users }}"
    
    - name: Configure firewall for PostgreSQL
      firewalld:
        port: 5432/tcp
        permanent: yes
        state: enabled
        immediate: yes
      when: ansible_os_family == "RedHat"
  
  handlers:
    - name: restart postgresql
      service:
        name: "postgresql-{{ postgresql_version }}"
        state: restarted
```

### PostgreSQL Configuration Templates

```jinja2
# templates/postgresql.conf.j2
# PostgreSQL configuration file

# Connection settings
listen_addresses = '{{ postgresql_listen_addresses | default("*") }}'
port = {{ postgresql_port | default("5432") }}
max_connections = {{ postgresql_max_connections | default("200") }}

# Memory settings
shared_buffers = {{ postgresql_shared_buffers | default("128MB") }}
effective_cache_size = {{ postgresql_effective_cache_size | default("1GB") }}
work_mem = {{ postgresql_work_mem | default("4MB") }}
maintenance_work_mem = {{ postgresql_maintenance_work_mem | default("64MB") }}

# WAL settings
wal_level = {{ postgresql_wal_level | default("replica") }}
max_wal_senders = {{ postgresql_max_wal_senders | default("3") }}
wal_keep_segments = {{ postgresql_wal_keep_segments | default("32") }}

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_min_duration_statement = {{ postgresql_log_min_duration | default("1000") }}

# Locale settings
lc_messages = '{{ postgresql_locale | default("en_US.UTF-8") }}'
lc_monetary = '{{ postgresql_locale | default("en_US.UTF-8") }}'
lc_numeric = '{{ postgresql_locale | default("en_US.UTF-8") }}'
lc_time = '{{ postgresql_locale | default("en_US.UTF-8") }}'
default_text_search_config = 'pg_catalog.english'
```

```jinja2
# templates/pg_hba.conf.j2
# PostgreSQL Client Authentication Configuration File

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Local connections
local   all             postgres                                peer
local   all             all                                     md5

# IPv4 local connections
host    all             all             127.0.0.1/32            md5

# IPv6 local connections
host    all             all             ::1/128                 md5

# Application connections
{% for subnet in postgresql_allowed_subnets | default(['192.168.1.0/24']) %}
host    all             all             {{ subnet }}            md5
{% endfor %}

# Replication connections
{% for subnet in postgresql_replication_subnets | default(['192.168.1.0/24']) %}
host    replication     replicator      {{ subnet }}            md5
{% endfor %}
```

## MongoDB Setup

### MongoDB Installation and Configuration

```yaml
# playbooks/mongodb-setup.yml
---
- name: Install and configure MongoDB
  hosts: databases
  become: yes
  vars:
    mongodb_version: "6.0"
    mongodb_databases:
      - name: petclinic
      - name: analytics
      - name: logs
    
    mongodb_users:
      - database: admin
        name: admin
        password: "{{ vault_mongodb_admin_password }}"
        roles: root
      - database: petclinic
        name: petclinic_user
        password: "{{ vault_petclinic_password }}"
        roles: readWrite
      - database: analytics
        name: analytics_user
        password: "{{ vault_analytics_password }}"
        roles: readWrite
  
  tasks:
    - name: Add MongoDB repository key
      rpm_key:
        key: https://www.mongodb.org/static/pgp/server-{{ mongodb_version }}.asc
        state: present
      when: ansible_os_family == "RedHat"
    
    - name: Add MongoDB repository
      yum_repository:
        name: mongodb-org-{{ mongodb_version }}
        description: MongoDB Repository
        baseurl: "https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/{{ mongodb_version }}/x86_64/"
        gpgcheck: yes
        enabled: yes
      when: ansible_os_family == "RedHat"
    
    - name: Install MongoDB packages
      package:
        name:
          - mongodb-org
          - python3-pymongo
        state: present
    
    - name: Configure MongoDB
      template:
        src: mongod.conf.j2
        dest: /etc/mongod.conf
        owner: root
        group: root
        mode: '0644'
      notify: restart mongodb
    
    - name: Start and enable MongoDB service
      service:
        name: mongod
        state: started
        enabled: yes
    
    - name: Wait for MongoDB to start
      wait_for:
        port: 27017
        delay: 10
        timeout: 60
    
    - name: Create MongoDB admin user
      mongodb_user:
        database: admin
        name: "{{ item.name }}"
        password: "{{ item.password }}"
        roles: "{{ item.roles }}"
        state: present
      loop: "{{ mongodb_users | selectattr('database', 'equalto', 'admin') | list }}"
      when: mongodb_users | selectattr('database', 'equalto', 'admin') | list | length > 0
    
    - name: Create MongoDB databases
      mongodb_db:
        name: "{{ item.name }}"
        state: present
        login_user: admin
        login_password: "{{ vault_mongodb_admin_password }}"
      loop: "{{ mongodb_databases }}"
    
    - name: Create MongoDB application users
      mongodb_user:
        database: "{{ item.database }}"
        name: "{{ item.name }}"
        password: "{{ item.password }}"
        roles: "{{ item.roles }}"
        state: present
        login_user: admin
        login_password: "{{ vault_mongodb_admin_password }}"
      loop: "{{ mongodb_users | rejectattr('database', 'equalto', 'admin') | list }}"
    
    - name: Configure firewall for MongoDB
      firewalld:
        port: 27017/tcp
        permanent: yes
        state: enabled
        immediate: yes
      when: ansible_os_family == "RedHat"
  
  handlers:
    - name: restart mongodb
      service:
        name: mongod
        state: restarted
```

### MongoDB Configuration Template

```yaml
# templates/mongod.conf.j2
# MongoDB configuration file

# Network interfaces
net:
  port: {{ mongodb_port | default(27017) }}
  bindIp: {{ mongodb_bind_ip | default('0.0.0.0') }}

# Storage
storage:
  dbPath: {{ mongodb_dbpath | default('/var/lib/mongo') }}
  journal:
    enabled: {{ mongodb_journal_enabled | default(true) }}

# Process management
processManagement:
  fork: true
  pidFilePath: {{ mongodb_pidfile | default('/var/run/mongodb/mongod.pid') }}

# Logging
systemLog:
  destination: file
  logAppend: true
  path: {{ mongodb_logpath | default('/var/log/mongodb/mongod.log') }}
  logRotate: {{ mongodb_log_rotate | default('rename') }}

# Security
security:
  authorization: {{ mongodb_auth_enabled | default('enabled') }}

# Replication (if enabled)
{% if mongodb_replication_enabled | default(false) %}
replication:
  replSetName: {{ mongodb_replica_set_name | default('rs0') }}
{% endif %}

# Sharding (if enabled)
{% if mongodb_sharding_enabled | default(false) %}
sharding:
  clusterRole: {{ mongodb_cluster_role | default('shardsvr') }}
{% endif %}
```

## Database Backup and Restore

### MySQL Backup Playbook

```yaml
# playbooks/mysql-backup.yml
---
- name: MySQL backup and restore operations
  hosts: databases
  become: yes
  vars:
    backup_dir: /backup/mysql
    mysql_root_password: "{{ vault_mysql_root_password }}"
    databases_to_backup:
      - petclinic_customers
      - petclinic_visits
      - petclinic_vets
  
  tasks:
    - name: Create backup directory
      file:
        path: "{{ backup_dir }}"
        state: directory
        owner: mysql
        group: mysql
        mode: '0750'
    
    - name: Install backup tools
      package:
        name:
          - mysql
          - gzip
        state: present
    
    - name: Create database backups
      mysql_db:
        name: "{{ item }}"
        state: dump
        target: "{{ backup_dir }}/{{ item }}_{{ ansible_date_time.date }}.sql"
        login_user: root
        login_password: "{{ mysql_root_password }}"
      loop: "{{ databases_to_backup }}"
    
    - name: Compress backup files
      archive:
        path: "{{ backup_dir }}/{{ item }}_{{ ansible_date_time.date }}.sql"
        dest: "{{ backup_dir }}/{{ item }}_{{ ansible_date_time.date }}.sql.gz"
        format: gz
        remove: yes
      loop: "{{ databases_to_backup }}"
    
    - name: Remove old backups (keep 7 days)
      find:
        paths: "{{ backup_dir }}"
        age: 7d
        patterns: "*.sql.gz"
      register: old_backups
    
    - name: Delete old backup files
      file:
        path: "{{ item.path }}"
        state: absent
      loop: "{{ old_backups.files }}"
    
    - name: Create backup script
      template:
        src: mysql-backup.sh.j2
        dest: /usr/local/bin/mysql-backup.sh
        mode: '0755'
    
    - name: Schedule daily backups
      cron:
        name: "MySQL daily backup"
        minute: "0"
        hour: "2"
        job: "/usr/local/bin/mysql-backup.sh"
        user: root
```

### Database Monitoring Setup

```yaml
# playbooks/database-monitoring.yml
---
- name: Setup database monitoring
  hosts: databases
  become: yes
  
  tasks:
    - name: Install monitoring tools
      package:
        name:
          - mysql
          - python3-pymysql
          - python3-psycopg2
          - python3-pymongo
        state: present
    
    - name: Create monitoring user for MySQL
      mysql_user:
        name: monitor
        password: "{{ vault_monitor_password }}"
        priv: "*.*:PROCESS,REPLICATION CLIENT,SELECT"
        host: "localhost"
        state: present
        login_user: root
        login_password: "{{ vault_mysql_root_password }}"
      when: "'mysql' in group_names"
    
    - name: Create monitoring script
      template:
        src: db-monitor.py.j2
        dest: /usr/local/bin/db-monitor.py
        mode: '0755'
    
    - name: Schedule monitoring checks
      cron:
        name: "Database monitoring"
        minute: "*/5"
        job: "/usr/local/bin/db-monitor.py"
        user: root
```

This comprehensive database setup guide provides production-ready examples for MySQL, PostgreSQL, and MongoDB deployment and management using Ansible.