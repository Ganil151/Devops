# Network Security for DevOps

Comprehensive network security implementations for DevOps environments. This section covers firewall architectures, intrusion detection/prevention systems, network access control, and security monitoring strategies.

## 🎯 Learning Objectives

- Design and implement comprehensive firewall architectures
- Deploy and configure intrusion detection/prevention systems
- Implement network access control (NAC) solutions
- Set up security monitoring and logging systems
- Understand threat detection and incident response procedures

## 🛡️ Firewall Architectures

### Firewall Types and Deployment Models

**Packet Filtering Firewalls:**
```bash
# iptables packet filtering example
# Default deny policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow specific services
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Log dropped packets
iptables -A INPUT -j LOG --log-prefix "DROPPED: "
iptables -A INPUT -j DROP
```

**Stateful Firewalls:**
```bash
# Advanced iptables with connection tracking
# Create custom chains
iptables -N SECURITY_RULES
iptables -N LOG_DROP

# Connection state rules
iptables -A INPUT -m state --state INVALID -j LOG_DROP
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW -j SECURITY_RULES

# Rate limiting for SSH
iptables -A SECURITY_RULES -p tcp --dport 22 -m recent --set --name SSH
iptables -A SECURITY_RULES -p tcp --dport 22 -m recent --update --seconds 60 --hitcount 4 --name SSH -j LOG_DROP
iptables -A SECURITY_RULES -p tcp --dport 22 -j ACCEPT

# Logging chain
iptables -A LOG_DROP -j LOG --log-prefix "SECURITY_DROP: " --log-level 4
iptables -A LOG_DROP -j DROP
```

**Application Layer Firewalls (WAF):**
```nginx
# Nginx with ModSecurity WAF
load_module modules/ngx_http_modsecurity_module.so;

http {
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/main.conf;
    
    server {
        listen 80;
        server_name example.com;
        
        location / {
            modsecurity_rules '
                SecRule ARGS "@detectSQLi" \
                    "id:1001,phase:2,block,msg:\'SQL Injection Attack\'"
                SecRule ARGS "@detectXSS" \
                    "id:1002,phase:2,block,msg:\'XSS Attack\'"
            ';
            proxy_pass http://backend;
        }
    }
}
```

### Network Segmentation Strategies

**DMZ Architecture:**
```
Internet
    │
┌───▼────┐
│Firewall│
└───┬────┘
    │
┌───▼────┐ DMZ
│ Switch │ ├── Web Servers
└───┬────┘ ├── Mail Servers
    │      └── DNS Servers
┌───▼────┐
│Firewall│
└───┬────┘
    │
┌───▼────┐ Internal Network
│ Switch │ ├── Application Servers
└────────┘ ├── Database Servers
           └── Workstations
```

**Multi-Tier Security:**
```bash
# Firewall rules for multi-tier architecture
# Web tier (DMZ) - Allow HTTP/HTTPS from Internet
iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT

# App tier - Allow only from web tier
iptables -A FORWARD -s 192.168.1.0/24 -d 192.168.2.0/24 -p tcp --dport 8080 -j ACCEPT

# Database tier - Allow only from app tier
iptables -A FORWARD -s 192.168.2.0/24 -d 192.168.3.0/24 -p tcp --dport 3306 -j ACCEPT
iptables -A FORWARD -s 192.168.2.0/24 -d 192.168.3.0/24 -p tcp --dport 5432 -j ACCEPT

# Deny all other inter-VLAN traffic
iptables -A FORWARD -j LOG --log-prefix "INTER_VLAN_DENY: "
iptables -A FORWARD -j DROP
```

### Next-Generation Firewall (NGFW) Configuration

**Palo Alto Networks Configuration:**
```xml
<security>
  <rules>
    <entry name="Web-Traffic-Allow">
      <from>
        <member>trust</member>
      </from>
      <to>
        <member>untrust</member>
      </to>
      <source>
        <member>192.168.1.0/24</member>
      </source>
      <destination>
        <member>any</member>
      </destination>
      <application>
        <member>web-browsing</member>
        <member>ssl</member>
      </application>
      <service>
        <member>application-default</member>
      </service>
      <action>allow</action>
      <profile-setting>
        <profiles>
          <virus>
            <member>default</member>
          </virus>
          <spyware>
            <member>default</member>
          </spyware>
          <vulnerability>
            <member>default</member>
          </vulnerability>
          <url-filtering>
            <member>default</member>
          </url-filtering>
        </profiles>
      </profile-setting>
    </entry>
  </rules>
</security>
```

**Fortinet FortiGate Configuration:**
```bash
# Configure security policies
config firewall policy
    edit 1
        set name "LAN-to-WAN"
        set srcintf "internal"
        set dstintf "wan1"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set utm-status enable
        set av-profile "default"
        set ips-sensor "default"
        set application-list "default"
        set ssl-ssh-profile "certificate-inspection"
    next
end
```

## 🔍 Intrusion Detection and Prevention Systems

### IDS vs IPS Comparison

| Feature | IDS | IPS |
|---------|-----|-----|
| Deployment | Out-of-band | Inline |
| Response | Passive (alerts) | Active (blocking) |
| Performance Impact | Minimal | Can introduce latency |
| Detection Method | Signature + Anomaly | Signature + Anomaly |
| False Positives | Less critical | Can block legitimate traffic |

### Snort IDS/IPS Configuration

**Snort Installation and Configuration:**
```bash
# Install Snort
sudo apt-get update
sudo apt-get install snort

# Configure Snort
sudo nano /etc/snort/snort.conf

# Key configuration sections:
# Network variables
var HOME_NET 192.168.1.0/24
var EXTERNAL_NET !$HOME_NET
var DNS_SERVERS $HOME_NET
var SMTP_SERVERS $HOME_NET
var HTTP_SERVERS $HOME_NET

# Preprocessors
preprocessor frag3_global: max_frags 65536
preprocessor frag3_engine: policy windows detect_anomalies overlap_limit 10
preprocessor stream5_global: track_tcp yes, track_udp yes, track_icmp no
preprocessor http_inspect: global iis_unicode_map unicode.map 1252
```

**Custom Snort Rules:**
```bash
# /etc/snort/rules/local.rules

# Detect SSH brute force attempts
alert tcp $EXTERNAL_NET any -> $HOME_NET 22 (msg:"SSH Brute Force Attempt"; \
    flow:to_server,established; content:"SSH"; threshold:type both, \
    track by_src, count 5, seconds 60; sid:1000001; rev:1;)

# Detect SQL injection attempts
alert tcp $EXTERNAL_NET any -> $HOME_NET 80 (msg:"SQL Injection Attempt"; \
    flow:to_server,established; content:"union"; nocase; content:"select"; \
    nocase; distance:0; within:100; sid:1000002; rev:1;)

# Detect port scanning
alert tcp $EXTERNAL_NET any -> $HOME_NET any (msg:"Port Scan Detected"; \
    flags:S; threshold:type both, track by_src, count 10, seconds 60; \
    sid:1000003; rev:1;)

# Detect large file uploads
alert tcp $EXTERNAL_NET any -> $HOME_NET 80 (msg:"Large File Upload"; \
    flow:to_server,established; dsize:>1000000; sid:1000004; rev:1;)
```

**Running Snort:**
```bash
# Test configuration
sudo snort -T -c /etc/snort/snort.conf

# Run in IDS mode
sudo snort -A console -q -c /etc/snort/snort.conf -i eth0

# Run in IPS mode (inline)
sudo snort -Q --daq afpacket -i eth0:eth1 -c /etc/snort/snort.conf
```

### Suricata IDS/IPS

**Suricata Configuration:**
```yaml
# /etc/suricata/suricata.yaml
vars:
  address-groups:
    HOME_NET: "[192.168.1.0/24]"
    EXTERNAL_NET: "!$HOME_NET"
    HTTP_SERVERS: "$HOME_NET"
    SMTP_SERVERS: "$HOME_NET"
    SQL_SERVERS: "$HOME_NET"
    DNS_SERVERS: "$HOME_NET"

af-packet:
  - interface: eth0
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
    use-mmap: yes
    tpacket-v3: yes

outputs:
  - fast:
      enabled: yes
      filename: fast.log
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
      types:
        - alert
        - http
        - dns
        - tls
        - files
        - smtp
```

**Custom Suricata Rules:**
```bash
# /etc/suricata/rules/local.rules

# Detect cryptocurrency mining
alert http $HOME_NET any -> $EXTERNAL_NET any (msg:"Cryptocurrency Mining Detected"; \
    content:"stratum+tcp"; http_uri; sid:2000001; rev:1;)

# Detect DNS tunneling
alert dns $HOME_NET any -> any 53 (msg:"DNS Tunneling Detected"; \
    dns_query; content:"|00|"; byte_test:1,>,50,0,relative; sid:2000002; rev:1;)

# Detect lateral movement
alert tcp $HOME_NET any -> $HOME_NET 445 (msg:"SMB Lateral Movement"; \
    flow:to_server,established; content:"|ff|SMB"; offset:4; depth:8; \
    sid:2000003; rev:1;)
```

### OSSEC Host-Based IDS

**OSSEC Server Configuration:**
```xml
<!-- /var/ossec/etc/ossec.conf -->
<ossec_config>
  <global>
    <email_notification>yes</email_notification>
    <email_to>admin@example.com</email_to>
    <smtp_server>localhost</smtp_server>
    <email_from>ossec@example.com</email_from>
  </global>

  <rules>
    <include>rules_config.xml</include>
    <include>pam_rules.xml</include>
    <include>sshd_rules.xml</include>
    <include>telnetd_rules.xml</include>
    <include>syslog_rules.xml</include>
    <include>arpwatch_rules.xml</include>
    <include>symantec-av_rules.xml</include>
    <include>symantec-ws_rules.xml</include>
    <include>pix_rules.xml</include>
    <include>named_rules.xml</include>
    <include>smbd_rules.xml</include>
    <include>vsftpd_rules.xml</include>
    <include>pure-ftpd_rules.xml</include>
    <include>proftpd_rules.xml</include>
    <include>ms_ftpd_rules.xml</include>
    <include>ftpd_rules.xml</include>
    <include>hordeimp_rules.xml</include>
    <include>roundcube_rules.xml</include>
    <include>wordpress_rules.xml</include>
    <include>cimserver_rules.xml</include>
    <include>vpopmail_rules.xml</include>
    <include>vmpop3d_rules.xml</include>
    <include>courier_rules.xml</include>
    <include>web_rules.xml</include>
    <include>web_appsec_rules.xml</include>
    <include>apache_rules.xml</include>
    <include>nginx_rules.xml</include>
    <include>php_rules.xml</include>
    <include>mysql_rules.xml</include>
    <include>postgresql_rules.xml</include>
    <include>ids_rules.xml</include>
    <include>squid_rules.xml</include>
    <include>firewall_rules.xml</include>
    <include>cisco-ios_rules.xml</include>
    <include>netscreenfw_rules.xml</include>
    <include>sonicwall_rules.xml</include>
    <include>postfix_rules.xml</include>
    <include>sendmail_rules.xml</include>
    <include>imapd_rules.xml</include>
    <include>mailscanner_rules.xml</include>
    <include>dovecot_rules.xml</include>
    <include>ms-exchange_rules.xml</include>
    <include>racoon_rules.xml</include>
    <include>vpn_concentrator_rules.xml</include>
    <include>spamd_rules.xml</include>
    <include>msauth_rules.xml</include>
    <include>mcafee_av_rules.xml</include>
    <include>trend-osce_rules.xml</include>
    <include>ms-se_rules.xml</include>
    <include>zeus_rules.xml</include>
    <include>solaris_bsm_rules.xml</include>
    <include>vmware_rules.xml</include>
    <include>ms_dhcp_rules.xml</include>
    <include>asterisk_rules.xml</include>
    <include>ossec_rules.xml</include>
    <include>attack_rules.xml</include>
    <include>local_rules.xml</include>
  </rules>

  <syscheck>
    <frequency>79200</frequency>
    <directories check_all="yes">/etc,/usr/bin,/usr/sbin</directories>
    <directories check_all="yes">/bin,/sbin,/boot</directories>
    <ignore>/etc/mtab</ignore>
    <ignore>/etc/hosts.deny</ignore>
    <ignore>/etc/mail/statistics</ignore>
    <ignore>/etc/random-seed</ignore>
    <ignore>/etc/random.seed</ignore>
    <ignore>/etc/adjtime</ignore>
    <ignore>/etc/httpd/logs</ignore>
    <ignore>/etc/utmpx</ignore>
    <ignore>/etc/wtmpx</ignore>
    <ignore>/etc/cups/certs</ignore>
    <ignore>/etc/dumpdates</ignore>
    <ignore>/etc/svc/volatile</ignore>
  </syscheck>

  <rootcheck>
    <rootkit_files>/var/ossec/etc/shared/rootkit_files.txt</rootkit_files>
    <rootkit_trojans>/var/ossec/etc/shared/rootkit_trojans.txt</rootkit_trojans>
    <system_audit>/var/ossec/etc/shared/system_audit_rcl.txt</system_audit>
    <system_audit>/var/ossec/etc/shared/system_audit_ssh.txt</system_audit>
    <system_audit>/var/ossec/etc/shared/cis_debian_linux_rcl.txt</system_audit>
    <system_audit>/var/ossec/etc/shared/cis_rhel_linux_rcl.txt</system_audit>
    <system_audit>/var/ossec/etc/shared/cis_rhel5_linux_rcl.txt</system_audit>
  </rootcheck>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/messages</location>
  </localfile>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/secure</location>
  </localfile>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/maillog</location>
  </localfile>

  <localfile>
    <log_format>apache</log_format>
    <location>/var/log/httpd/error_log</location>
  </localfile>

  <localfile>
    <log_format>apache</log_format>
    <location>/var/log/httpd/access_log</location>
  </localfile>

  <remote>
    <connection>secure</connection>
    <port>1514</port>
    <protocol>udp</protocol>
  </remote>
</ossec_config>
```

## 🔐 Network Access Control (NAC)

### 802.1X Authentication

**FreeRADIUS Configuration:**
```bash
# /etc/freeradius/3.0/clients.conf
client switch1 {
    ipaddr = 192.168.1.10
    secret = shared_secret_key
    require_message_authenticator = yes
    nas_type = cisco
}

client switch2 {
    ipaddr = 192.168.1.11
    secret = shared_secret_key
    require_message_authenticator = yes
    nas_type = cisco
}
```

```bash
# /etc/freeradius/3.0/users
# User authentication
john    Cleartext-Password := "password123"
        Reply-Message = "Welcome John",
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = 10

jane    Cleartext-Password := "password456"
        Reply-Message = "Welcome Jane",
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = 20

# Default for unknown users
DEFAULT Auth-Type := Reject
        Reply-Message = "Access Denied"
```

**Switch Configuration (Cisco):**
```bash
# Enable AAA
aaa new-model
aaa authentication dot1x default group radius
aaa authorization network default group radius

# Configure RADIUS server
radius server RADIUS1
 address ipv4 192.168.1.100 auth-port 1812 acct-port 1813
 key shared_secret_key

# Configure 802.1X globally
dot1x system-auth-control

# Configure interface for 802.1X
interface FastEthernet0/1
 switchport mode access
 switchport access vlan 999  # Quarantine VLAN
 authentication host-mode single-host
 authentication port-control auto
 authentication periodic
 authentication timer restart 3600
 dot1x pae authenticator
 dot1x timeout tx-period 10
```

### MAC Address Filtering

**Dynamic VLAN Assignment:**
```bash
# /etc/freeradius/3.0/users
# MAC-based authentication
00-11-22-33-44-55    Cleartext-Password := "00-11-22-33-44-55"
                     Reply-Message = "Corporate Device",
                     Tunnel-Type = VLAN,
                     Tunnel-Medium-Type = IEEE-802,
                     Tunnel-Private-Group-Id = 10

aa-bb-cc-dd-ee-ff    Cleartext-Password := "aa-bb-cc-dd-ee-ff"
                     Reply-Message = "Guest Device",
                     Tunnel-Type = VLAN,
                     Tunnel-Medium-Type = IEEE-802,
                     Tunnel-Private-Group-Id = 100
```

### Certificate-Based Authentication

**EAP-TLS Configuration:**
```bash
# Generate CA certificate
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt

# Generate server certificate
openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -out server.crt

# Generate client certificate
openssl genrsa -out client.key 4096
openssl req -new -key client.key -out client.csr
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -out client.crt
```

## 📊 Security Monitoring and Logging

### Centralized Logging with ELK Stack

**Elasticsearch Configuration:**
```yaml
# /etc/elasticsearch/elasticsearch.yml
cluster.name: security-logs
node.name: node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node
xpack.security.enabled: true
```

**Logstash Configuration:**
```ruby
# /etc/logstash/conf.d/security.conf
input {
  beats {
    port => 5044
  }
  
  syslog {
    port => 514
    type => "syslog"
  }
  
  tcp {
    port => 5000
    type => "firewall"
  }
}

filter {
  if [type] == "firewall" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{WORD:action} %{IP:src_ip}:%{INT:src_port} -> %{IP:dst_ip}:%{INT:dst_port}" }
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    mutate {
      convert => { "src_port" => "integer" }
      convert => { "dst_port" => "integer" }
    }
  }
  
  if [type] == "suricata" {
    json {
      source => "message"
    }
    
    if [event_type] == "alert" {
      mutate {
        add_tag => [ "security_alert" ]
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "security-logs-%{+YYYY.MM.dd}"
  }
  
  if "security_alert" in [tags] {
    email {
      to => "security@example.com"
      subject => "Security Alert: %{alert.signature}"
      body => "Alert detected: %{message}"
    }
  }
}
```

**Kibana Dashboard Configuration:**
```json
{
  "version": "7.10.0",
  "objects": [
    {
      "id": "security-dashboard",
      "type": "dashboard",
      "attributes": {
        "title": "Security Monitoring Dashboard",
        "hits": 0,
        "description": "Network security monitoring and alerting",
        "panelsJSON": "[{\"version\":\"7.10.0\",\"gridData\":{\"x\":0,\"y\":0,\"w\":24,\"h\":15,\"i\":\"1\"},\"panelIndex\":\"1\",\"embeddableConfig\":{},\"panelRefName\":\"panel_1\"}]",
        "timeRestore": false,
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"query\":{\"match_all\":{}},\"filter\":[]}"
        }
      }
    }
  ]
}
```

### SIEM Integration

**Splunk Universal Forwarder:**
```bash
# /opt/splunkforwarder/etc/system/local/inputs.conf
[monitor:///var/log/suricata/eve.json]
disabled = false
sourcetype = suricata
index = security

[monitor:///var/log/snort/alert]
disabled = false
sourcetype = snort
index = security

[monitor:///var/log/iptables.log]
disabled = false
sourcetype = iptables
index = security

[udp://514]
disabled = false
sourcetype = syslog
index = security
```

**Security Metrics Collection:**
```python
#!/usr/bin/env python3
# security_metrics.py

import json
import time
import requests
from datetime import datetime, timedelta

class SecurityMetrics:
    def __init__(self, elasticsearch_url):
        self.es_url = elasticsearch_url
    
    def get_alert_count(self, time_range="1h"):
        query = {
            "query": {
                "bool": {
                    "must": [
                        {"term": {"event_type": "alert"}},
                        {"range": {"@timestamp": {"gte": f"now-{time_range}"}}}
                    ]
                }
            }
        }
        
        response = requests.post(
            f"{self.es_url}/security-logs-*/_count",
            json=query,
            headers={"Content-Type": "application/json"}
        )
        
        return response.json()["count"]
    
    def get_top_attackers(self, limit=10):
        query = {
            "size": 0,
            "query": {
                "bool": {
                    "must": [
                        {"term": {"event_type": "alert"}},
                        {"range": {"@timestamp": {"gte": "now-24h"}}}
                    ]
                }
            },
            "aggs": {
                "top_attackers": {
                    "terms": {
                        "field": "src_ip",
                        "size": limit
                    }
                }
            }
        }
        
        response = requests.post(
            f"{self.es_url}/security-logs-*/_search",
            json=query,
            headers={"Content-Type": "application/json"}
        )
        
        return response.json()["aggregations"]["top_attackers"]["buckets"]
    
    def generate_report(self):
        report = {
            "timestamp": datetime.now().isoformat(),
            "alerts_last_hour": self.get_alert_count("1h"),
            "alerts_last_24h": self.get_alert_count("24h"),
            "top_attackers": self.get_top_attackers()
        }
        
        return json.dumps(report, indent=2)

# Usage
if __name__ == "__main__":
    metrics = SecurityMetrics("http://localhost:9200")
    print(metrics.generate_report())
```

## 🚨 Incident Response Procedures

### Automated Response Scripts

**IP Blocking Script:**
```bash
#!/bin/bash
# block_ip.sh - Automatically block malicious IPs

IP_TO_BLOCK=$1
REASON=$2
LOG_FILE="/var/log/security_blocks.log"

if [ -z "$IP_TO_BLOCK" ]; then
    echo "Usage: $0 <IP_ADDRESS> [REASON]"
    exit 1
fi

# Validate IP address format
if ! [[ $IP_TO_BLOCK =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Invalid IP address format"
    exit 1
fi

# Check if IP is already blocked
if iptables -L INPUT -n | grep -q "$IP_TO_BLOCK"; then
    echo "IP $IP_TO_BLOCK is already blocked"
    exit 0
fi

# Block the IP
iptables -I INPUT -s "$IP_TO_BLOCK" -j DROP

# Log the action
echo "$(date): Blocked IP $IP_TO_BLOCK - Reason: $REASON" >> "$LOG_FILE"

# Send notification
echo "Security Alert: IP $IP_TO_BLOCK has been blocked due to: $REASON" | \
    mail -s "Security Block Notification" security@example.com

echo "IP $IP_TO_BLOCK has been successfully blocked"
```

**Incident Response Playbook:**
```yaml
# incident_response.yml
incident_types:
  brute_force_attack:
    detection_criteria:
      - "Failed login attempts > 10 in 5 minutes"
      - "Source: Single IP address"
    
    response_actions:
      1. "Block source IP address"
      2. "Notify security team"
      3. "Increase monitoring on affected service"
      4. "Review authentication logs"
    
    escalation_criteria:
      - "Attack continues from multiple IPs"
      - "Successful authentication detected"
    
    recovery_steps:
      1. "Verify attack has stopped"
      2. "Review blocked IPs for false positives"
      3. "Update security policies if needed"

  malware_detection:
    detection_criteria:
      - "Antivirus alert triggered"
      - "Suspicious network traffic patterns"
    
    response_actions:
      1. "Isolate affected system"
      2. "Preserve evidence"
      3. "Run full system scan"
      4. "Notify incident response team"
    
    escalation_criteria:
      - "Malware spreads to other systems"
      - "Data exfiltration detected"
```

### Security Orchestration Script

```python
#!/usr/bin/env python3
# security_orchestrator.py

import json
import subprocess
import smtplib
from email.mime.text import MIMEText
from datetime import datetime

class SecurityOrchestrator:
    def __init__(self, config_file):
        with open(config_file, 'r') as f:
            self.config = json.load(f)
    
    def block_ip(self, ip_address, reason):
        """Block IP address using iptables"""
        try:
            cmd = f"iptables -I INPUT -s {ip_address} -j DROP"
            subprocess.run(cmd, shell=True, check=True)
            
            self.log_action(f"Blocked IP {ip_address}: {reason}")
            self.send_notification(f"IP Blocked: {ip_address}", reason)
            
            return True
        except subprocess.CalledProcessError as e:
            self.log_action(f"Failed to block IP {ip_address}: {e}")
            return False
    
    def isolate_host(self, hostname):
        """Isolate host by blocking all traffic"""
        try:
            # Get host IP from hostname
            import socket
            ip_address = socket.gethostbyname(hostname)
            
            # Block all traffic to/from host
            cmd1 = f"iptables -I INPUT -s {ip_address} -j DROP"
            cmd2 = f"iptables -I OUTPUT -d {ip_address} -j DROP"
            
            subprocess.run(cmd1, shell=True, check=True)
            subprocess.run(cmd2, shell=True, check=True)
            
            self.log_action(f"Isolated host {hostname} ({ip_address})")
            self.send_notification(f"Host Isolated: {hostname}", f"IP: {ip_address}")
            
            return True
        except Exception as e:
            self.log_action(f"Failed to isolate host {hostname}: {e}")
            return False
    
    def send_notification(self, subject, message):
        """Send email notification"""
        try:
            msg = MIMEText(f"{message}\n\nTimestamp: {datetime.now()}")
            msg['Subject'] = f"[SECURITY ALERT] {subject}"
            msg['From'] = self.config['email']['from']
            msg['To'] = ', '.join(self.config['email']['to'])
            
            server = smtplib.SMTP(self.config['email']['smtp_server'])
            server.send_message(msg)
            server.quit()
            
        except Exception as e:
            self.log_action(f"Failed to send notification: {e}")
    
    def log_action(self, message):
        """Log security actions"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"{timestamp} - {message}\n"
        
        with open(self.config['log_file'], 'a') as f:
            f.write(log_entry)
    
    def process_alert(self, alert_data):
        """Process security alert and take appropriate action"""
        alert_type = alert_data.get('type')
        severity = alert_data.get('severity', 'medium')
        
        if alert_type == 'brute_force':
            source_ip = alert_data.get('source_ip')
            if source_ip:
                self.block_ip(source_ip, "Brute force attack detected")
        
        elif alert_type == 'malware':
            hostname = alert_data.get('hostname')
            if hostname and severity == 'high':
                self.isolate_host(hostname)
        
        elif alert_type == 'data_exfiltration':
            # High priority - immediate notification
            self.send_notification(
                "CRITICAL: Data Exfiltration Detected",
                f"Details: {json.dumps(alert_data, indent=2)}"
            )

# Configuration file example
config_example = {
    "email": {
        "smtp_server": "localhost",
        "from": "security@example.com",
        "to": ["admin@example.com", "security-team@example.com"]
    },
    "log_file": "/var/log/security_orchestrator.log"
}

# Usage example
if __name__ == "__main__":
    orchestrator = SecurityOrchestrator("security_config.json")
    
    # Example alert processing
    alert = {
        "type": "brute_force",
        "severity": "high",
        "source_ip": "192.168.1.100",
        "target": "ssh",
        "attempts": 15
    }
    
    orchestrator.process_alert(alert)
```

## ✅ Knowledge Check

Before proceeding, ensure you can:
- [ ] Design multi-layer firewall architectures
- [ ] Configure and deploy IDS/IPS systems
- [ ] Implement network access control solutions
- [ ] Set up centralized security logging
- [ ] Create automated incident response procedures
- [ ] Monitor and analyze security metrics
- [ ] Integrate security tools with SIEM platforms

## 🔗 Next Steps

- **[VPN Technologies](../VPN-Technologies/)** - Secure remote connectivity
- **[Advanced Level](../../Advanced-Level/)** - Cloud-native security
- **[Service Mesh Security](../../Advanced-Level/Service-Mesh/)** - Microservices security

---

*Network security is critical for protecting modern infrastructure. Implement these practices to build robust, secure network environments.*