# Nmap Scanning: Network Discovery & Security

Nmap ("Network Mapper") is an open-source tool for network exploration and security auditing. For a DevOps engineer, it's the primary tool for verifying firewall configurations and identifying running services.

## 🎯 When to Use Nmap in DevOps
- Checking if a **Security Group** or **WAF** change correctly blocked a port.
- Discovering all active hosts in a new **VPC** CIDR block.
- Identifying the exact **Version** of a web server (e.g., Nginx 1.21.0).
- Running basic **Security Audits** before a production release.

---

## 🏗️ Essential Scan Types

| Scan Type | Flag | Description |
| :--- | :--- | :--- |
| **Ping Scan** | `-sn` | Just check if hosts are alive, don't scan ports. |
| **Stealth Scan** | `-sS` | Default (Syn Scan). Doesn't complete the TCP handshake. |
| **Connect Scan**| `-sT` | Completes the TCP handshake (used if `-sS` isn't possible). |
| **UDP Scan** | `-sU` | Scans for UDP services (DNS, DHCP, SNMP). Slow but critical. |

### ⚡ Timing & Optimization (Nmap Cookbook Method)
Nmap's speed can be adjusted to balance accuracy with network politeness:
- `-T0` (Paranoid): Extremely slow, used to bypass old IDS.
- `-T3` (Normal): The default speed.
- `-T4` (Aggressive): Recommended for most DevOps work on high-speed reliable networks.
- `-T5` (Insane): Very fast, but likely to drop packets or trigger security alerts.

**Pro Tip**: Use `--max-retries 1` to speed up scans on reliable internal networks.

---

## 🚀 Powerful DevOps Commands

### 1. Service & Version Detection
Identify what is actually running on the open ports.
```bash
# Scan common ports and try to identify service versions
nmap -sV 10.0.1.50

# Aggressive scan (OS detection, Version detection, Script scanning, Traceroute)
nmap -A 10.0.1.50
```

### 2. Scanning Whole Networks
Find every active instance in a subnet.
```bash
# List all active hosts in a /24 subnet
nmap -sn 10.0.1.0/24
```

### 3. Port Filtering
```bash
# Scan specific ports
nmap -p 80,443,8080 10.0.1.50

# Scan all 65535 ports (Slow!)
nmap -p- 10.0.1.50
```

### 4. Output for Automation
Save results to files for parsing in CI/CD pipelines.
```bash
# Normal, XML, and Grepable output formats
nmap -p 80 10.0.1.0/24 -oA network_audit
```

---

## 🛡️ The Nmap Scripting Engine (NSE)
Nmap has hundreds of built-in scripts to automate tasks like vulnerability checking.
```bash
# Check for common vulnerabilities on a web server
nmap --script vuln 10.0.1.50

# Check for SSL/TLS vulnerabilities
nmap --script ssl-enum-ciphers -p 443 google.com
```

---

## 💡 Best Practices & Ethics
- **Authorized Only**: Never scan networks you don't own or have explicit permission to audit.
- **Cloud Throttling**: Some cloud providers (like AWS) may flag or block accounts performing aggressive scans on their infrastructure without prior notice.
- **Quiet Scans**: Use `-T3` or `-T2` for slower, more subtle scans if you want to avoid triggering IDS (Intrusion Detection Systems).

---

## ✅ Knowledge Check
- [ ] Scan your own local machine to see open ports.
- [ ] Use `-sV` to identify the version of a running service (e.g., SSH).
- [ ] Perform a ping scan on a local network range.
- [ ] Export results to an XML file.
