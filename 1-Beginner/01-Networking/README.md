# Networking Foundations

Networking is the plumbing of the internet. For a DevOps engineer, understanding how data moves through a network is critical for debugging connectivity and securing services.

---

## 1. The OSI Model (Simplified)

While there are 7 layers, DevOps engineers focus on these core areas:
- **Layer 3 (Network)**: Routing and IP addresses.
- **Layer 4 (Transport)**: TCP vs. UDP and Port numbers.
- **Layer 7 (Application)**: HTTP, DNS, and TLS.

---

## 2. Core Concepts
- **IP Addressing**: Public vs. Private IPs.
- **Subnetting**: Dividing a network into smaller, manageable segments.
- **DNS**: The phonebook of the internet. Converting `example.com` to an IP.
- **Load Balancing**: Distributing traffic across multiple servers.

---

## 3. Tooling Reference
- **Check Connectivity**: `ping`, `telnet`, `nc` (Netcat).
- **Trace Route**: `traceroute` to see where a packet is dropping.
- **DNS Lookup**: `dig`, `nslookup`.
- **Interface Info**: `ip addr`, `ifconfig`.

---

## 4. Best Practices
1. **Private by Default**: Keep your databases and internal servers in private subnets.
2. **Ports**: Close all ports by default; only open the ones you explicitly need (e.g., 80, 443).
3. **Encryption**: Always prefer HTTPS (TLS) over plain HTTP.

---

## 🛠️ The DevOps Toolbelt
Mastering theory is only half the battle. You must master the diagnostic and scanning tools used in the field:
- **[Networking Tools Deep Dive](./Networking-Tools/README.md)**: Master **Wireshark**, **Nmap**, and **Tcpdump**.

 **Next Step**: Learn how to securely log into these networked systems in the [Linux Basics Module](../02-Linux-Basics/README.md).