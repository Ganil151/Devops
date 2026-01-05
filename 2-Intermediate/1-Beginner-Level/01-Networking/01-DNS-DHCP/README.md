# Advanced DNS and DHCP Management for DevOps

Enterprise-grade DNS and DHCP services for scalable network infrastructure. This section covers high availability, security, and automation for critical network services.

## 🎯 Learning Objectives

- Deploy redundant DNS server architectures
- Implement advanced DHCP features and failover
- Configure DNS security extensions (DNSSEC)
- Set up dynamic DNS and service discovery
- Automate DNS/DHCP management with APIs

## 🌐 Advanced DNS Implementation

### DNS Server Clustering

**BIND9 Master-Slave Configuration:**

**Master Server (ns1.example.com):**
```bash
# /etc/bind/named.conf.local
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
    allow-transfer { 192.168.1.11; 192.168.1.12; };
    notify yes;
    also-notify { 192.168.1.11; 192.168.1.12; };
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.1";
    allow-transfer { 192.168.1.11; 192.168.1.12; };
    notify yes;
};
```

**Slave Server (ns2.example.com):**
```bash
# /etc/bind/named.conf.local
zone "example.com" {
    type slave;
    file "/var/cache/bind/db.example.com";
    masters { 192.168.1.10; };
};

zone "1.168.192.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.192.168.1";
    masters { 192.168.1.10; };
};
```

### DNS Load Balancing

**Round-Robin DNS:**
```bash
# /etc/bind/db.example.com
$TTL    300
@       IN      SOA     ns1.example.com. admin.example.com. (
                        2023010101      ; Serial
                        3600            ; Refresh
                        1800            ; Retry
                        604800          ; Expire
                        300 )           ; Minimum TTL

; Name servers
@       IN      NS      ns1.example.com.
@       IN      NS      ns2.example.com.

; Load balanced web servers
www     IN      A       192.168.1.100
www     IN      A       192.168.1.101
www     IN      A       192.168.1.102

; Weighted records (BIND 9.12+)
api     IN      A       192.168.1.110   ; Weight 10
api     IN      A       192.168.1.111   ; Weight 5
```

### Geographic DNS (GeoDNS)

**PowerDNS with GeoIP:**
```sql
-- PowerDNS MySQL schema
CREATE TABLE domains (
  id INT AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  master VARCHAR(128) DEFAULT NULL,
  last_check INT DEFAULT NULL,
  type VARCHAR(6) NOT NULL,
  notified_serial INT DEFAULT NULL,
  account VARCHAR(40) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE records (
  id INT AUTO_INCREMENT,
  domain_id INT DEFAULT NULL,
  name VARCHAR(255) DEFAULT NULL,
  type VARCHAR(10) DEFAULT NULL,
  content VARCHAR(64000) DEFAULT NULL,
  ttl INT DEFAULT NULL,
  prio INT DEFAULT NULL,
  change_date INT DEFAULT NULL,
  disabled TINYINT(1) DEFAULT 0,
  ordername VARCHAR(255) BINARY DEFAULT NULL,
  auth TINYINT(1) DEFAULT 1,
  PRIMARY KEY (id)
);

-- Geographic records
INSERT INTO records (domain_id, name, type, content, ttl) VALUES
(1, 'www.example.com', 'A', '192.168.1.100', 300),  -- US servers
(1, 'www.example.com', 'A', '10.0.1.100', 300);     -- EU servers
```

## 🔒 DNS Security (DNSSEC)

### DNSSEC Implementation

**Zone Signing:**
```bash
# Generate zone signing keys
dnssec-keygen -a RSASHA256 -b 2048 -n ZONE example.com
dnssec-keygen -a RSASHA256 -b 4096 -f KSK -n ZONE example.com

# Sign the zone
dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum | cut -b 1-16) \
    -N INCREMENT -o example.com -t db.example.com

# Update named.conf
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com.signed";
    key-directory "/etc/bind/keys/";
    auto-dnssec maintain;
    inline-signing yes;
};
```

**DNSSEC Validation:**
```bash
# /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    
    dnssec-validation auto;
    dnssec-lookaside auto;
    
    auth-nxdomain no;
    listen-on-v6 { any; };
    
    # Root key for validation
    managed-keys-directory "/var/cache/bind/dynamic";
};
```

### DNS over HTTPS (DoH) and DNS over TLS (DoT)

**Unbound DoT Configuration:**
```bash
# /etc/unbound/unbound.conf
server:
    interface: 0.0.0.0@853
    tls-service-key: "/etc/unbound/unbound_server.key"
    tls-service-pem: "/etc/unbound/unbound_server.pem"
    tls-port: 853
    
    # Forward to upstream DoT servers
forward-zone:
    name: "."
    forward-tls-upstream: yes
    forward-addr: 1.1.1.1@853#cloudflare-dns.com
    forward-addr: 8.8.8.8@853#dns.google
```

## 📡 Dynamic DNS (DDNS)

### BIND9 Dynamic Updates

**DDNS Configuration:**
```bash
# Generate update key
dnssec-keygen -a HMAC-MD5 -b 128 -n HOST ddns-key

# /etc/bind/named.conf.local
key "ddns-key" {
    algorithm hmac-md5;
    secret "generated-key-here";
};

zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
    allow-update { key "ddns-key"; };
    update-policy {
        grant ddns-key zonesub ANY;
    };
};
```

**Client Update Script:**
```bash
#!/bin/bash
# ddns-update.sh

KEY_FILE="/etc/bind/ddns-key.private"
SERVER="192.168.1.10"
ZONE="example.com"
HOSTNAME="dynamic.example.com"

# Get current public IP
CURRENT_IP=$(curl -s ifconfig.me)

# Update DNS record
nsupdate -k "$KEY_FILE" <<EOF
server $SERVER
zone $ZONE
update delete $HOSTNAME A
update add $HOSTNAME 300 A $CURRENT_IP
send
EOF

echo "Updated $HOSTNAME to $CURRENT_IP"
```

### PowerDNS API Integration

**API-based DNS Management:**
```python
#!/usr/bin/env python3
import requests
import json

class PowerDNSAPI:
    def __init__(self, server_url, api_key):
        self.server_url = server_url
        self.headers = {
            'X-API-Key': api_key,
            'Content-Type': 'application/json'
        }
    
    def create_record(self, zone, name, record_type, content, ttl=300):
        url = f"{self.server_url}/api/v1/servers/localhost/zones/{zone}"
        
        rrsets = {
            "rrsets": [
                {
                    "name": name,
                    "type": record_type,
                    "changetype": "REPLACE",
                    "records": [
                        {
                            "content": content,
                            "disabled": False
                        }
                    ],
                    "ttl": ttl
                }
            ]
        }
        
        response = requests.patch(url, headers=self.headers, json=rrsets)
        return response.status_code == 204
    
    def delete_record(self, zone, name, record_type):
        url = f"{self.server_url}/api/v1/servers/localhost/zones/{zone}"
        
        rrsets = {
            "rrsets": [
                {
                    "name": name,
                    "type": record_type,
                    "changetype": "DELETE"
                }
            ]
        }
        
        response = requests.patch(url, headers=self.headers, json=rrsets)
        return response.status_code == 204

# Usage
dns_api = PowerDNSAPI("http://localhost:8081", "your-api-key")
dns_api.create_record("example.com.", "test.example.com.", "A", "192.168.1.100")
```

## 🏠 Advanced DHCP Configuration

### DHCP Failover and Load Balancing

**ISC DHCP Failover:**

**Primary Server:**
```bash
# /etc/dhcp/dhcpd.conf
failover peer "dhcp-failover" {
    primary;
    address 192.168.1.10;
    port 647;
    peer address 192.168.1.11;
    peer port 647;
    max-response-delay 30;
    max-unacked-updates 10;
    load balance max seconds 3;
    mclt 1800;
    split 128;
}

subnet 192.168.1.0 netmask 255.255.255.0 {
    pool {
        failover peer "dhcp-failover";
        range 192.168.1.100 192.168.1.200;
    }
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.10, 192.168.1.11;
    option domain-name "example.com";
}
```

**Secondary Server:**
```bash
# /etc/dhcp/dhcpd.conf
failover peer "dhcp-failover" {
    secondary;
    address 192.168.1.11;
    port 647;
    peer address 192.168.1.10;
    peer port 647;
    max-response-delay 30;
    max-unacked-updates 10;
    load balance max seconds 3;
}

subnet 192.168.1.0 netmask 255.255.255.0 {
    pool {
        failover peer "dhcp-failover";
        range 192.168.1.100 192.168.1.200;
    }
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.10, 192.168.1.11;
}
```

### DHCP Relay and Superscopes

**DHCP Relay Configuration:**
```bash
# Cisco router DHCP relay
interface vlan10
 ip address 192.168.10.1 255.255.255.0
 ip helper-address 192.168.1.10
 ip helper-address 192.168.1.11

interface vlan20
 ip address 192.168.20.1 255.255.255.0
 ip helper-address 192.168.1.10
 ip helper-address 192.168.1.11
```

**Multi-VLAN DHCP Server:**
```bash
# /etc/dhcp/dhcpd.conf
shared-network office-network {
    subnet 192.168.10.0 netmask 255.255.255.0 {
        range 192.168.10.100 192.168.10.200;
        option routers 192.168.10.1;
        option domain-name "sales.example.com";
    }
    
    subnet 192.168.20.0 netmask 255.255.255.0 {
        range 192.168.20.100 192.168.20.200;
        option routers 192.168.20.1;
        option domain-name "engineering.example.com";
    }
}
```

## 🔍 Service Discovery Integration

### Consul DNS Integration

**Consul Configuration:**
```hcl
# /etc/consul/consul.hcl
datacenter = "dc1"
data_dir = "/opt/consul/data"
log_level = "INFO"
server = true
bootstrap_expect = 3

bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"

ports {
  dns = 8600
}

recursors = ["8.8.8.8", "8.8.4.4"]

connect {
  enabled = true
}
```

**Service Registration:**
```json
{
  "service": {
    "name": "web",
    "tags": ["frontend", "nginx"],
    "port": 80,
    "check": {
      "http": "http://localhost:80/health",
      "interval": "10s"
    }
  }
}
```

**DNS Forwarding to Consul:**
```bash
# /etc/bind/named.conf.local
zone "consul" {
    type forward;
    forward only;
    forwarders { 127.0.0.1 port 8600; };
};
```

### Kubernetes DNS Integration

**CoreDNS Configuration:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . 8.8.8.8 8.8.4.4 {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
    
    example.com:53 {
        errors
        cache 30
        forward . 192.168.1.10 192.168.1.11
    }
```

## 🤖 DNS/DHCP Automation

### Terraform DNS Management

**AWS Route53 Configuration:**
```hcl
# dns.tf
resource "aws_route53_zone" "main" {
  name = "example.com"
  
  tags = {
    Environment = "production"
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"
  ttl     = "300"
  records = ["192.168.1.100", "192.168.1.101"]
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api"
  type    = "CNAME"
  ttl     = "300"
  records = ["api-lb.us-west-2.elb.amazonaws.com"]
}

# Health check
resource "aws_route53_health_check" "api" {
  fqdn                            = "api.example.com"
  port                            = 443
  type                            = "HTTPS"
  resource_path                   = "/health"
  failure_threshold               = "3"
  request_interval                = "30"
  
  tags = {
    Name = "API Health Check"
  }
}
```

### Ansible DNS/DHCP Management

**DNS Zone Management:**
```yaml
# dns-management.yml
---
- name: Manage DNS zones and records
  hosts: dns_servers
  become: yes
  
  vars:
    dns_zones:
      - name: example.com
        type: master
        records:
          - { name: "www", type: "A", value: "192.168.1.100" }
          - { name: "mail", type: "A", value: "192.168.1.110" }
          - { name: "ftp", type: "CNAME", value: "www.example.com" }
  
  tasks:
    - name: Install BIND9
      package:
        name: bind9
        state: present
    
    - name: Configure named.conf.local
      template:
        src: named.conf.local.j2
        dest: /etc/bind/named.conf.local
        backup: yes
      notify: restart bind9
    
    - name: Create zone files
      template:
        src: zone.j2
        dest: "/etc/bind/db.{{ item.name }}"
      loop: "{{ dns_zones }}"
      notify: restart bind9
    
    - name: Validate configuration
      command: named-checkconf
      changed_when: false
  
  handlers:
    - name: restart bind9
      service:
        name: bind9
        state: restarted
```

## 📊 Monitoring and Logging

### DNS Query Logging

**BIND9 Query Logging:**
```bash
# /etc/bind/named.conf.local
logging {
    channel query_log {
        file "/var/log/bind/query.log" versions 3 size 5m;
        severity info;
        print-category yes;
        print-severity yes;
        print-time yes;
    };
    
    category queries { query_log; };
};
```

### DHCP Lease Monitoring

**DHCP Lease Analysis Script:**
```python
#!/usr/bin/env python3
import re
import datetime
from collections import defaultdict

def parse_dhcp_leases(lease_file):
    leases = defaultdict(dict)
    
    with open(lease_file, 'r') as f:
        content = f.read()
    
    # Parse lease entries
    lease_pattern = r'lease (\d+\.\d+\.\d+\.\d+) \{([^}]+)\}'
    
    for match in re.finditer(lease_pattern, content, re.DOTALL):
        ip = match.group(1)
        lease_data = match.group(2)
        
        # Extract lease information
        starts = re.search(r'starts \d+ ([^;]+);', lease_data)
        ends = re.search(r'ends \d+ ([^;]+);', lease_data)
        hardware = re.search(r'hardware ethernet ([^;]+);', lease_data)
        hostname = re.search(r'client-hostname "([^"]+)";', lease_data)
        
        if starts and ends:
            leases[ip] = {
                'starts': starts.group(1),
                'ends': ends.group(1),
                'hardware': hardware.group(1) if hardware else 'Unknown',
                'hostname': hostname.group(1) if hostname else 'Unknown'
            }
    
    return leases

def generate_report(leases):
    print("DHCP Lease Report")
    print("=" * 50)
    
    active_leases = 0
    expired_leases = 0
    now = datetime.datetime.now()
    
    for ip, data in leases.items():
        try:
            end_time = datetime.datetime.strptime(data['ends'], '%Y/%m/%d %H:%M:%S')
            if end_time > now:
                active_leases += 1
                status = "ACTIVE"
            else:
                expired_leases += 1
                status = "EXPIRED"
        except:
            status = "UNKNOWN"
        
        print(f"{ip:<15} {data['hostname']:<20} {data['hardware']:<18} {status}")
    
    print(f"\nSummary: {active_leases} active, {expired_leases} expired")

# Usage
leases = parse_dhcp_leases('/var/lib/dhcp/dhcpd.leases')
generate_report(leases)
```

## ✅ Knowledge Check

- [ ] Configure DNS master-slave replication
- [ ] Implement DNSSEC for zone security
- [ ] Set up DHCP failover and load balancing
- [ ] Configure dynamic DNS updates
- [ ] Integrate with service discovery systems
- [ ] Automate DNS/DHCP management
- [ ] Monitor DNS/DHCP performance

## 🔗 Next Steps

- [Network Security](../Network-Security/) - DNS/DHCP security hardening
- [Advanced Level](../../Advanced-Level/) - Cloud DNS integration
- [Service Mesh](../../Advanced-Level/Service-Mesh/) - Service discovery patterns