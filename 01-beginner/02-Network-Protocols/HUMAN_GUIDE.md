# 🌐 02: Network Protocols (The Handshake of the Internet)

> **"Networking is the art of making sure your message doesn't get lost in a crowd of billions."**

In DevOps, software is a team sport. Your app can't talk to the database without a network. Your users can't see your website without a network. Understanding the "layers" of how data moves is the difference between a Junior who says "it's broken" and a Senior who says "The TCP handshake is timing out at the Load Balancer."

---

## 🗺️ The Narrative: Your Journey

### Phase 1: The Seven Layers (OSI Model)
Before a single bit leaves your computer, it goes through the **OSI Model**.
- **Analogy**: Sending a package via FedEx. 
  - **Application (L7)**: The letter you wrote.
  - **Transport (L4)**: The tracking number and insurance.
  - **Network (L3)**: The address on the box (IP).
  - **Physical (L1)**: The truck carrying the box.

### Phase 2: The Address Book (IP Addressing & DNS)
Every server needs an address (IP) and a human-readable name (DNS).
- **The DevOps Why**: We use DNS names because IP addresses change constantly in the cloud. We point our code at `database.internal`, not `10.0.1.45`.

### Phase 3: The Traffic Police (Protocols & Ports)
HTTP (80), HTTPS (443), SSH (22). Ports are like "apartment numbers" in a building.
- **The "Handshake"**: When you run a **Docker Container**, you "map" the host port to the container port. This port forwarding is a network-level handshake that allows external traffic into an isolated container.

### Phase 4: Fixing the Leak (Troubleshooting)
Tools like `ping`, `traceroute`, `telnet`, and `curl` are your stethoscope.
- **Senior Tip**: If `ping` works but `curl` fails, the server is "up," but the **Application** isn't listening on the right port.

---

## 🏗️ Architectural Overview
<NETWORK_PROTOCOLS_DIAGRAM>

---

## 🆘 What to do when this fails: Network Edition

**Issue: "Connection Refused"**
- **The Fix**: The server is alive, but nothing is listening on that port. Check the service status or firewall rules (`netstat -tulpn`).

**Issue: "Name or service not known"**
- **The Fix**: Your **DNS** is failing. Check `/etc/resolv.conf` or try `dig <domain>` to see where the lookup is breaking.

---

## 🚦 Pro-Tips for SREs
> **Localhost is for loners**: Inside a container, `127.0.0.1` refers to the container itself. To talk to other containers or the host, you must use their **Docker Network** names.

---
*Visit the [Assessment/](./Assessment/) folder to test your knowledge!*
