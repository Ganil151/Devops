# Nagios: Infrastructure Monitoring & Alerting

Nagios is an enterprise-class monitoring solution for hosts, services, and networks. It provides a robust framework for detecting outages, performance issues, and security vulnerabilities across distributed environments.

---

## 🏛️ Architecture & Connectivity

Nagios operates on a server-client model. To monitor remote resources, it uses specialized agents.

### 1. NRPE (Nagios Remote Plugin Executor)
NRPE allows you to execute Nagios plugins on many remote Linux/Unix machines. This allows you to monitor local resources (like CPU load, memory usage, etc.) that aren't usually exposed to external machines.

**Data Flow**:
`Nagios Server` -> `check_nrpe` plugin -> `Remote Host (NRPE Daemon)` -> `Local Plugin` -> `Result`

### 2. NRPE Configuration Example (`/etc/nagios/nrpe.cfg`)
On the remote host, you must define which commands NRPE is allowed to run:
```text
allowed_hosts=127.0.0.1, 10.0.0.50  # IP of your Nagios Server
dont_blame_nrpe=0                   # Security: Don't allow command arguments

# Command Definitions
command[check_users]=/usr/lib/nagios/plugins/check_users -w 5 -c 10
command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
```

---

## 🔍 Enterprise Scaling: Groups & Templates

Nagios uses an object-oriented approach to configuration, reducing redundancy.

### Service Groups
Organize services for consolidated viewing (e.g., "All HTTP Services" across 50 servers).
```text
define servicegroup {
    servicegroup_name   web-services
    alias               Web Server Health
    members             web01,HTTP,web02,HTTP,web03,HTTP
}
```

### Contact Groups
Ensure the right people are alerted for specific failures.
```text
define contactgroup {
    contactgroup_name   admins
    alias               Nagios Administrators
    members             ganil, system_lead
}
```

---

## 🛠️ Custom Plugin Example (Bash)
You can write your own monitoring logic. Nagios only cares about the **Exit Code**.

**Script**: `check_my_app.sh`
```bash
#!/bin/bash
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)

if [ "$STATUS" == "200" ]; then
    echo "OK - Application is healthy"
    exit 0
elif [ "$STATUS" == "500" ]; then
    echo "CRITICAL - Application returned 500 error"
    exit 2
else
    echo "WARNING - Application returned status: $STATUS"
    exit 1
fi
```

---

## ⚠️ The Nagios Philosophy: Binary State
Nagios is the master of **State-Based Monitoring**.
- **Hard State**: A failure that has persisted for `max_check_attempts`. This triggers an alert.
- **Soft State**: A temporary failure (e.g., a network blip). Nagios re-checks before alerting.

---

**Next Steps**: Return to the [Observability Home](../readme.md) for more advanced monitoring patterns.
