# 🌐 Networking Concepts: The Global Infrastructure

> **"If you don't understand how the packet gets delivered, you'll never be able to build a global system. In the cloud, networking is code."**

---

## 🏗️ Essential Protocols & Ports
DevOps engineers must memorize these ports like their own phone number.

| Protocol | Port | DevOps Why |
| :--- | :--- | :--- |
| **HTTP** | 80 | Standard web traffic (Redirect to 443!). |
| **HTTPS** | 443 | Secure web traffic (TLS/SSL). |
| **SSH** | 22 | Remote server management. |
| **DNS** | 53 | Translating "google.com" to an IP address. |
| **DBs** | 3306/5432 | MySQL/PostgreSQL (Never expose to the internet!). |

---

## 🗺️ TCP/IP Stack & OSI Model
Understanding layers helps you identify WHERE a failure is occurring.

<TCP_IP_STACK_MAP>

> **Senior Tip**: When a service is down, always check the layers: **Ping** (Layer 3), then **Telnet/nc** (Layer 4), then **Curl** (Layer 7). Don't jump to the app code until the network is verified.

---

## 🛠️ The Networking Toolbelt (Essential Commands)
| Command | Purpose | Senior Tip |
| :--- | :--- | :--- |
| `dig` | DNS Lookup | Use `+short` for quick IP answers in scripts. |
| `nc` (Netcat) | Port Check | `nc -zv <ip> <port>` is the fastest way to check a firewall. |
| `mtr` | Traceroute + Ping | Best tool for finding exactly where a packet is dropping. |
| `curl -v` | HTTP Debugging | Shows the full headers, including status codes and redirects. |

---

## 📂 Learning Path

1. **[Network Fundamentals](./01-network-fundamentals/readme.md)**: Physical topologies and core terminology.
2. **[Network Models](./02-network-models/readme.md)**: Deep dive into OSI and TCP/IP.
3. **[IP Addressing](./03-ip-addressing/readme.md)**: IPv4, IPv6, and Subnetting.
4. **[Basic Protocols](./04-basic-protocols/readme.md)**: HTTP, DNS, DHCP, TCP/UDP.
5. **[Network Devices](./05-network-devices/readme.md)**: Load Balancers and Firewalls.
6. **[Basic Troubleshooting](./06-basic-troubleshooting/readme.md)**: SRE Diagnostic Playbook.

---

**Next Step**: Start with [Network Fundamentals](./01-network-fundamentals/readme.md)
