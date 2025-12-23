# Tcpdump Mastery: Command-Line Packet Capture

`tcpdump` is the most powerful and widely used command-line packet sniffer. It's the "Swiss Army Knife" for network troubleshooting on remote Linux servers where a GUI (like Wireshark) isn't available.

## 🎯 When to Use Tcpdump in DevOps
- Capturing traffic on a **Remote Server** via SSH.
- Troubleshooting **Connectivity** between two back-end microservices.
- Verifying **NAT** or **Routing** logic on a Linux bastion host.
- Capturing a specific event (e.g., a rare error) for later analysis in Wireshark.

---

## 🏗️ Essential CLI Flags

| Flag | Description |
| :--- | :--- |
| `-i <int>`| Specify interface (e.g., `eth0`, `any`). |
| `-n` | Don't resolve hostnames (show IPs). Essential for speed. |
| `-nn` | Don't resolve hostnames OR port names (show port numbers). |
| `-v, -vv` | Verbose output (shows TTL, ID, length, etc.). |
| `-X` | Show packet content in both Hex and ASCII. |
| `-c <num>` | Exit after capturing `num` packets. |
| `-w <file>`| Write raw packets to a `.pcap` file for Wireshark. |
| `-r <file>`| Read back from a `.pcap` file. |

---

## 🔍 The Power of BPF Filters
Tcpdump uses the **Berkeley Packet Filter** syntax to surgically pick the traffic you care about.

```bash
# Capture only traffic from a specific host
sudo tcpdump -i eth0 host 10.0.1.50

# Capture only traffic going TO a specific port
sudo tcpdump -i eth0 dst port 80

# Capture only TCP traffic
sudo tcpdump -i eth0 tcp

# Complex filters (Logic: and, or, not)
sudo tcpdump -i eth0 'host 10.0.1.50 and (port 80 or port 443)'

# Everything except SSH (To avoid seeing your own traffic)
sudo tcpdump -i eth0 not port 22
```

---

## 🚀 Pro Workflows

### 1. Capture and Analyze Later (The Standard)
Capture on the server, then download and open in Wireshark.
```bash
# On the server: Capture 100 packets of web traffic
sudo tcpdump -i eth0 port 80 -c 100 -w web_issue.pcap

# On your local machine:
scp user@server:~/web_issue.pcap ./
wireshark web_issue.pcap
```

### 2. Stream to Local Wireshark (Advanced)
Stream the server's traffic directly to your local GUI over SSH.
```bash
ssh user@server 'sudo tcpdump -i eth0 -U -w - "not port 22"' | wireshark -k -i -
```

### 3. Check for Packet Drops
Look for "ICMP Unreachable" messages.
```bash
sudo tcpdump -i any icmp
```

---

## 💡 Best Practices
- **`any` interface**: Use `-i any` to see traffic on all interfaces at once (useful for checking routing).
- **`-nn` is your friend**: Resolving DNS or service names for every packet during an outage can slow down the tool and flood the terminal.
- **Watch the Disk**: Writing a lot of traffic to a `.pcap` file can fill up your server's disk space quickly. Use `-c` to limit the capture.

---

## ✅ Knowledge Check
- [ ] List all available network interfaces (`tcpdump -D`).
- [ ] Capture traffic on a specific port with `-nn`.
- [ ] Write a capture to a file and read it back.
- [ ] Filter out your own SSH session from a capture.
