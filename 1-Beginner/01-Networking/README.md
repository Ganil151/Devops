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

## 4. Linux Networking Diagnostic Methodology
When a connection fails, follow this "inside-out" approach common in Linux administration:

1.  **Check Local Interface**: Is the NIC up? (`ip link`)
2.  **Check Local IP**: Does the machine have the expected IP? (`ip addr`)
3.  **Check Local Routing**: Is there a default gateway? (`ip route`)
4.  **Check Remote Reachability**: Can you ping the gateway? Can you ping `8.8.8.8`?
5.  **Check DNS**: Can you resolve a hostname? (`dig google.com`)
6.  **Check Application Port**: Is the service actually listening on the target port? (`ss -tuln`)

## 5. Security & Stability Best Practices
Based on industry standards and the *Linux Command Line* guide:
- **Minimize the Attack Surface**: Disable any network service you aren't using. Use `ss -tuln` to find "ghost" services.
- **Prefer Static IPs for Servers**: Use DHCP reservations or static configurations for critical infrastructure to avoid IP changes.
- **Monitor Bandwidth**: Use `iftop` or `nload` to identify processes hogging the connection.
- **Immutable Configurations**: In DevOps, define your network (VPCs, Security Groups) as code (e.g., Terraform) rather than manual 	"clicks."

---

## 🛠️ The DevOps Toolbelt
Mastering theory is only half the battle. You must master the diagnostic and scanning tools used in the field:
- **[Networking Tools Deep Dive](./Networking-Tools/README.md)**: Master **Wireshark**, **Nmap**, and **Tcpdump**.

 **Next Step**: Learn how to securely log into these networked systems in the [Linux Basics Module](../02-Linux-Basics/README.md).