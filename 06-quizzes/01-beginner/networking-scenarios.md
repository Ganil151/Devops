# Real-World Networking Scenarios Quiz

Test your troubleshooting skills with these common DevOps networking scenarios.

---

## 🏗️ Part 1: OSI Layer Troubleshooting

**Scenario 1: The "Dying" Hardware**
A server suddenly stops communicating. You notice the Link Light on the Network Interface Card (NIC) is off. After swapping the cable, the light stays off.
**Question:** Which OSI layer is definitely involved, and what is the next logical step?
- A) Layer 3; Check the IP address.
- B) Layer 1; Check the network port on the switch or try a different port.
- C) Layer 2; Check for MAC address conflicts.
- D) Layer 4; Check if the firewall is blocking ports.

**Scenario 2: The "Slow" Hub**
A small startup is using an old network hub to connect 20 developers. As more people join, everyone complains that the network is extremely slow and "noisy."
**Question:** Upgrading to which Layer 2 device would solve the collision problem, and why?
- A) A Router; because it routes packets.
- B) A Switch; because it creates dedicated collision domains for each port.
- C) A Repeater; because it strengthens the signal.
- D) A Bridge; because it connects two different types of cables.

**Scenario 3: The Subnet Mystery**
Host A (192.168.1.5/24) cannot ping Host B (192.168.1.130/25).
**Question:** Why is this communication failing?
- A) The IP addresses are identical.
- B) Host B is in a different subnet (192.168.1.128 - 192.168.1.255) and they need a router.
- C) Layer 2 addresses are not configured.
- D) Both hosts are in the same subnet, it must be a firewall issue.

**Scenario 4: The 3-Way Handshake Failure**
You run `tcpdump` and see your client sending a **SYN**, the server responding with a **SYN-ACK**, but then the server immediately sends a **RST (Reset)**.
**Question:** What does this sequence usually indicate?
- A) The port is closed.
- B) The server is accepting the connection but the application crashed mid-handshake.
- C) The network cable is unplugged.
- D) The client's IP is spoofed.

**Scenario 5: The Expired Identity**
A user tries to access a secure website, but the browser displays a "Your connection is not private" error. You check the server and find the configuration is correct, but the certificate date has passed.
**Question:** Which OSI layer handles this encryption/handshake validation?
- A) Layer 7 (Application)
- B) Layer 6 (Presentation)
- C) Layer 5 (Session)
- D) Layer 4 (Transport)

---

## 🛠️ Part 2: Tools & Diagnostics

**Scenario 6: The Invisible Service**
You know a web server is running on a VM, but you can't reach it on port 80. You want to see if the port is even "listening."
**Question:** Which command would you run *on the server* to verify the port is open and listening?
- A) `ping localhost`
- B) `netstat -tuln | grep :80`
- C) `traceroute localhost`
- D) `curl -v localhost`

**Scenario 7: The Packet Detective**
You suspect a "SYN Flood" attack is hitting your server. You need to see the raw flags of incoming packets in the terminal.
**Question:** Which command is best suited for this task on a headless Linux server?
- A) `wireshark`
- B) `nmap -sS`
- C) `tcpdump -i eth0 'tcp[tcpflags] & (tcp-syn) != 0'`
- D) `ip addr show`

**Scenario 8: The Version Hunter**
You are auditing a server and need to know exactly which version of Apache is running on port 80 without logging into the box.
**Question:** Which Nmap command provides this information?
- A) `nmap -p 80 <IP>`
- B) `nmap -sV -p 80 <IP>`
- C) `nmap -O <IP>`
- D) `nmap -sn <IP>`

**Scenario 9: Finding the Bottleneck**
A developer complains that "the network is slow" between their office and the data center. You want to see exactly which router (hop) is introducing latency.
**Question:** Which tool should you use?
- A) `ping`
- B) `traceroute` (or `mtr`)
- C) `dig`
- D) `nslookup`

**Scenario 10: DNS Divergence**
The website `myapp.com` works for you, but your colleague in a different office says it "doesn't exist."
**Question:** What is the first thing you should check using `dig` or `nslookup`?
- A) Check if port 443 is open.
- B) Check if the IP address is pingable.
- C) Check which DNS server each of you is using.
- D) Check the server's CPU usage.

---

## ☁️ Part 3: Cloud & Advanced Networking

**Scenario 11: The "Connection Refused" SG**
You deployed an EC2 instance in AWS. You can ping its public IP, but you cannot SSH into it (Port 22). Local `netstat` shows SSH is running on the instance.
**Question:** What is the most likely culprit?
- A) The Internet Gateway is missing.
- B) The Security Group doesn't have an Inbound Rule for port 22.
- C) The instance has no private IP.
- D) The SSH service is using UDP instead of TCP.

**Scenario 12: The Database Isolation**
Your Web Server is in a Public Subnet, and your Database is in a Private Subnet. The Web Server cannot connect to the Database.
**Question:** If the Security Groups are correct, what is the next thing to check at Layer 3?
- A) If the Database has a Public IP.
- B) The Route Table of the Public Subnet.
- C) The Network ACLs (NACLs) or the Route Table allowing internal traffic between subnets.
- D) The physical cable between the two servers.

**Scenario 13: 502 Bad Gateway**
Your Nginx Load Balancer is returning a 502 error.
**Question:** What does this technically mean in the context of the OSI model?
- A) Layer 3: The Load Balancer can't find the IP of the backend.
- B) Layer 7: The Load Balancer (Proxy) received an invalid response or no response from the backend application.
- C) Layer 1: The Load Balancer is unplugged.
- D) Layer 4: The TCP handshake with the client failed.

**Scenario 14: The Large Payload Timeout**
A file upload service works for small 1KB files but hangs and times out for 100MB files. You suspect an MTU mismatch in a GRE tunnel.
**Question:** Which layer/service handles the breaking of these large messages into segments?
- A) Layer 2 (Framing)
- B) Layer 4 (Segmentation & Reassembly)
- C) Layer 3 (Routing)
- D) Layer 7 (Application logic)

**Scenario 15: "Sticky" Session failure**
A user logs into your application, but every time they click a new page, they are asked to log in again. You have 3 backend servers behind a Load Balancer.
**Question:** Which OSI Layer 5 concept is failing, and how do Load Balancers typically solve it?
- A) Data encryption; using better ciphers.
- B) Session Management; using "Sticky Sessions" or "Session Affinity."
- C) Path Determination; using better routing protocols.
- D) Framing; by increasing the MTU.

---

## 🏁 Part 4: Mixed Scenarios

**Scenario 16: Telnet vs Curl**
You want to check if a remote server is accepting connections on port 3306 (MySQL), but you don't have the MySQL client installed.
**Question:** Which simple tool can you use to test if the "pipe" is open?
- A) `telnet <IP> 3306` (or `nc -zv <IP> 3306`)
- B) `ping <IP>`
- C) `ip link`
- D) `arp -a`

**Scenario 17: VLAN Hopping Prevention**
You want to ensure that the "Finance" department cannot talk to the "Guest" Wi-Fi users at all, even though they are plugged into the same physical switch.
**Question:** Which Layer 2 technology do you use?
- A) Subnetting
- B) VLANs (Virtual LANs)
- C) Proxy Servers
- D) DNS Filtering

**Scenario 18: ICMP Disabled**
A server is definitely running and responding to web requests, but `ping <IP>` returns "Request Timed Out."
**Question:** Why is this happening?
- A) The server is down.
- B) The server or a firewall is blocking ICMP (Internet Control Message Protocol) traffic.
- C) The server has no IP address.
- D) Pinging only works on local networks.

**Scenario 19: Public vs Private IP**
An instance in a cloud provider has a Private IP of `10.0.1.5` and a Public IP of `54.12.33.4`. You want to allow another instance *in the same VPC* to connect to it.
**Question:** Which IP should you use for the internal connection to reduce costs and improve speed?
- A) The Public IP.
- B) The Private IP.
- C) It doesn't matter.
- D) Use the MAC address instead.

**Scenario 20: The "Broken" Website**
You change the DNS record for `test.com` to a new IP, but you still see the old website when you visit it.
**Question:** What is the most likely reason?
- A) The server is too slow.
- B) DNS Caching (TTL - Time To Live) hasn't expired yet.
- C) The website is deleted.
- D) The new IP is incorrect.

---

## 🔑 Answer Key

1. **B** - Link light is a Physical Layer indicator. Checking the switch port is the next step.
2. **B** - Switches use MAC addresses to forward traffic to specific ports, creating separate collision domains.
3. **B** - /25 means the first subnet ends at .127. .130 is in the next subnet.
4. **A** - A SYN followed by a RST usually means the port is closed (nothing is listening).
5. **B** - Encryption, formatting, and certificate validation are Presentation Layer concerns.
6. **B** - `netstat` (or `ss`) shows listening sockets.
7. **C** - `tcpdump` is the go-to CLI tool for raw packet analysis.
8. **B** - `-sV` stands for Service Version detection.
9. **B** - `traceroute` shows each hop and its latency.
10. **C** - DNS propagation or local DNS server issues are the first things to check.
11. **B** - Security Groups are the primary L4 firewalls in AWS.
12. **C** - Subnet-to-subnet traffic requires proper routing and NACL permissions.
13. **B** - 502 means the proxy (ALB/Nginx) got no response from the "upstream" server.
14. **B** - Transport layer handles the segmentation of data.
15. **B** - Session affinity ensures the user stays on the same server where their session was created.
16. **A** - `telnet` or `nc` can attempt a TCP handshake on any port.
17. **B** - VLANs segment traffic at Layer 2.
18. **B** - ICMP is often blocked for "security by obscurity."
19. **B** - Internal traffic should always use private IPs for security and performance.
20. **B** - DNS records are cached based on the TTL value.
