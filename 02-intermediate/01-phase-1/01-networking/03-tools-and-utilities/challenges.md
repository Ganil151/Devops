# Networking Tools & Utilities Challenges 🛠️

Master the diagnostic tools that every DevOps engineer uses to find "The Ghost in the Machine."

---

## 🏆 Challenge 01: The Connectivity Swiss Army Knife
**Objective**: Master `Ncat` (nc) for port validation.

1.  **Task**: Run a simple listener on Port 9090 on one terminal.
2.  **Command**: `nc -l 9090`.
3.  **Action**: Connect from another terminal and send a "Hello" message.
4.  **DevOps Context**: How can you use `nc` to check if a remote Database port is open without having the database client installed?

---

## 🏆 Challenge 02: Deep Packet Inspection
**Objective**: Understand traffic flow with `tcpdump`.

1.  **Requirement**: Capture traffic on your primary interface (e.g., `eth0`).
2.  **Command**: Research the `tcpdump -i eth0 port 80` command.
3.  **Task**: Visit a non-HTTPS website and identify the "HTTP GET" request in the packet logs.
4.  **Security Question**: Why is it dangerous to use unencrypted protocols (HTTP, Telnet, FTP) on a professional network?

---

## 🏆 Challenge 03: DNS Debugging
**Objective**: Troubleshooting name resolution with `dig`.

1.  **Requirement**: Query the DNS records for `google.com`.
2.  **Steps**:
    *   Find the **A Record** (IPv4).
    *   Find the **MX Record** (Mail Servers).
    *   Find the **SOA Record** (Authority).
3.  **Bonus**: Query a specific DNS server (like Cloudflare 1.1.1.1) instead of your local resolver.

---

## 📁 Solutions
CLI cheat-sheets and command flags are located in the `Boilerplates/` directory.
