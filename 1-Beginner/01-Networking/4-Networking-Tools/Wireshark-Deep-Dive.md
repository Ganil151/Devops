# Wireshark Deep Dive: GUI Packet Analysis

Wireshark is the world’s foremost network protocol analyzer. It allows you to see what’s happening on your network at a microscopic level.

## 🎯 When to Use Wireshark in DevOps
- Debugging complex **TLS/SSL Handshake** failures.
- Investigating intermittent **HTTP 5xx** errors by looking at the raw TCP flow.
- Analyzing **DNS** resolution delays in a Kubernetes cluster.
- Decrypting and inspecting application payloads for troubleshooting (with appropriate certificates).

---

## 🏗️ Core Interface & Workflow

### 1. Capturing Traffic
Select an interface (e.g., `eth0` or `WiFi`) and click the blue shark fin icon.
> [!NOTE]
> On Linux, you often need `sudo` or specific group permissions to capture on physical interfaces.

### 2. Capture Filters vs. Display Filters
- **Capture Filters**: Set *before* you start. Limits what Wireshark actually records. (Syntax: `host 10.0.0.1`, `port 80`).
- **Display Filters**: Set *after* capturing. Hides packets from view but keeps them in memory. (Syntax: `ip.addr == 10.0.0.1`, `http.response.code == 404`).

---

## 🔍 Essential Display Filters for DevOps

| Goal | Filter Syntax |
| :--- | :--- |
| **IP Traffic** | `ip.addr == 192.168.1.1` |
| **TCP Port** | `tcp.port == 8080` |
| **HTTP Errors** | `http.response.code >= 400` |
| **DNS Queries** | `dns.flags.response == 0` |
| **TCP Retransmissions** | `tcp.analysis.retransmission` |
| **Find specific string** | `frame contains "password"` |

---

## 🚀 Advanced Power Features

### 1. "Follow TCP Stream"
Right-click any TCP packet and select **Follow > TCP Stream**.
This opens a window showing the entire conversation between client and server in plain text (if not encrypted), exactly as the application saw it.

### 2. Statistics and Graphs
- **Endpoint List**: See which IPs are generating the most traffic.
- **IO Graph**: Visualize traffic spikes over time.
- **Flow Graph**: A sequence diagram of the network conversation.

### 3. Decrypting TLS Traffic
1. Set an environment variable on your machine: `export SSLKEYLOGFILE=~/sslkeys.log`.
2. Open Chrome/Firefox; they will write session keys to this file.
3. In Wireshark: **Preferences > Protocols > TLS > (Pre)-Master-Secret log filename** pointing to that file.
4. You can now see the contents of HTTPS traffic!

---

## ✅ Knowledge Check
- [ ] Install Wireshark and capture local traffic.
- [ ] Filter for a specific website's IP address.
- [ ] Use "Follow TCP Stream" to see an HTTP request/response.
- [ ] Identify a TCP "Three-Way Handshake" (SYN, SYN-ACK, ACK).
