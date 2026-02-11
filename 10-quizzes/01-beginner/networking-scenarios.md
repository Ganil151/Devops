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

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The link light is a physical indicator of connectivity (Layer 1). If swapping the cable doesn't work, the issue is likely the physical port on the server or the switch.
**Certification Alignment:** CompTIA Network+ / AWS Certified Solutions Architect (Physical Connectivity)
</details>

**Scenario 2: The "Slow" Hub**
A small startup is using an old network hub to connect 20 developers. As more people join, everyone complains that the network is extremely slow and "noisy."
**Question:** Upgrading to which Layer 2 device would solve the collision problem, and why?
- A) A Router; because it routes packets.
- B) A Switch; because it creates dedicated collision domains for each port.
- C) A Repeater; because it strengthens the signal.
- D) A Bridge; because it connects two different types of cables.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Hubs broadcast traffic to all ports, causing "collisions." Switches use a MAC address table to send traffic only to the destination port, fundamentally increasing performance.
**Certification Alignment:** CompTIA Network+
</details>

**Scenario 3: The Subnet Mystery**
Host A (192.168.1.5/24) cannot ping Host B (192.168.1.130/25).
**Question:** Why is this communication failing?
- A) The IP addresses are identical.
- B) Host B is in a different subnet (192.168.1.128 - 192.168.1.255) and they need a router.
- C) Layer 2 addresses are not configured.
- D) Both hosts are in the same subnet, it must be a firewall issue.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** A /25 subnet splits the .0/24 network into two halves (.0-.127 and .128-.255). Host B is in the second half, while Host A is in the first half. They are logically on different networks.
**Certification Alignment:** CompTIA Network+ / CCNA (Subnetting)
</details>

**Scenario 4: The 3-Way Handshake Failure**
You run `tcpdump` and see your client sending a **SYN**, the server responding with a **SYN-ACK**, but then the server immediately sends a **RST (Reset)**.
**Question:** What does this sequence usually indicate?
- A) The port is closed.
- B) The server is accepting the connection but the application crashed mid-handshake.
- C) The network cable is unplugged.
- D) The client's IP is spoofed.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** A `RST` packet in response to a `SYN` is the OS's way of saying "I see your request, but I have no service listening on this port."
**Certification Alignment:** CompTIA Security+ / AWS Certified SysOps Administrator
</details>

**Scenario 5: The Expired Identity**
A user tries to access a secure website, but the browser displays a "Your connection is not private" error. You check the server and find the configuration is correct, but the certificate date has passed.
**Question:** Which OSI layer handles this encryption/handshake validation?
- A) Layer 7 (Application)
- B) Layer 6 (Presentation)
- C) Layer 5 (Session)
- D) Layer 4 (Transport)

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The Presentation Layer (Layer 6) is responsible for data translation, encryption (SSL/TLS), and formatting.
**Certification Alignment:** CompTIA Security+ / AWS Certified Solutions Architect (Encryption)
</details>

---

## 🛠️ Part 2: Tools & Diagnostics

**Scenario 6: The Invisible Service**
You know a web server is running on a VM, but you can't reach it on port 80. You want to see if the port is even "listening."
**Question:** Which command would you run *on the server* to verify the port is open and listening?
- A) `ping localhost`
- B) `netstat -tuln | grep :80`
- C) `traceroute localhost`
- D) `curl -v localhost`

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** `netstat` (or `ss`) shows active network sockets. `-t` (tcp), `-u` (udp), `-l` (listening), `-n` (numeric ports) is the standard combination to check for services.
**Certification Alignment:** CompTIA Linux+ / LPIC-1
</details>

**Scenario 7: The Packet Detective**
You suspect a "SYN Flood" attack is hitting your server. You need to see the raw flags of incoming packets in the terminal.
**Question:** Which command is best suited for this task on a headless Linux server?
- A) `wireshark`
- B) `nmap -sS`
- C) `tcpdump -i eth0 'tcp[tcpflags] & (tcp-syn) != 0'`
- D) `ip addr show`

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** `tcpdump` is the standard CLI tool for packet capture. Using filters allows you to isolate specific TCP flags like SYN.
**Certification Alignment:** CompTIA Security+ / AWS Certified Security Specialty
</details>

**Scenario 8: The Version Hunter**
You are auditing a server and need to know exactly which version of Apache is running on port 80 without logging into the box.
**Question:** Which Nmap command provides this information?
- A) `nmap -p 80 <IP>`
- B) `nmap -sV -p 80 <IP>`
- C) `nmap -O <IP>`
- D) `nmap -sn <IP>`

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The `-sV` flag probes open ports to determine the service name and version number.
**Certification Alignment:** CompTIA Pentest+ / AWS Certified Security Specialty
</details>

**Scenario 9: Finding the Bottleneck**
A developer complains that "the network is slow" between their office and the data center. You want to see exactly which router (hop) is introducing latency.
**Question:** Which tool should you use?
- A) `ping`
- B) `traceroute` (or `mtr`)
- C) `dig`
- D) `nslookup`

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** `traceroute` (and the diagnostic tool `mtr`) sends packets with increasing TTL values to map the path and measure latency at each intermediate hop.
**Certification Alignment:** CompTIA Network+ / AWS Certified SysOps Administrator
</details>

**Scenario 10: DNS Divergence**
The website `myapp.com` works for you, but your colleague in a different office says it "doesn't exist."
**Question:** What is the first thing you should check using `dig` or `nslookup`?
- A) Check if port 443 is open.
- B) Check if the IP address is pingable.
- C) Check which DNS server each of you is using.
- D) Check the server's CPU usage.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** If a record resolves differently for two people, they are likely using different DNS servers (e.g., local office DNS vs Google 8.8.8.8) which may be at different stages of propagation.
**Certification Alignment:** CompTIA Network+ / AWS Certified Solutions Architect (Route 53)
</details>

---

## ☁️ Part 3: Cloud & Advanced Networking

**Scenario 11: The "Connection Refused" SG**
You deployed an EC2 instance in AWS. You can ping its public IP, but you cannot SSH into it (Port 22). Local `netstat` shows SSH is running on the instance.
**Question:** What is the most likely culprit?
- A) The Internet Gateway is missing.
- B) The Security Group doesn't have an Inbound Rule for port 22.
- C) The instance has no private IP.
- D) The SSH service is using UDP instead of TCP.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Security Groups act as stateful firewalls. By default, they block all inbound traffic. You must explicitly allow port 22/TCP for SSH.
**Certification Alignment:** AWS Certified Cloud Practitioner / Solutions Architect Associate
</details>

**Scenario 12: The Database Isolation**
Your Web Server is in a Public Subnet, and your Database is in a Private Subnet. The Web Server cannot connect to the Database.
**Question:** If the Security Groups are correct, what is the next thing to check at Layer 3?
- A) If the Database has a Public IP.
- B) The Route Table of the Public Subnet.
- C) The Network ACLs (NACLs) or the Route Table allowing internal traffic between subnets.
- D) The physical cable between the two servers.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** NACLs are stateless firewalls at the subnet level. Even if the Security Group is open, a NACL rule (or a missing route) can block traffic between subnets.
**Certification Alignment:** AWS Certified Solutions Architect Associate (VPC Design)
</details>

**Scenario 13: 502 Bad Gateway**
Your Nginx Load Balancer is returning a 502 error.
**Question:** What does this technically mean in the context of the OSI model?
- A) Layer 3: The Load Balancer can't find the IP of the backend.
- B) Layer 7: The Load Balancer (Proxy) received an invalid response or no response from the backend application.
- C) Layer 1: The Load Balancer is unplugged.
- D) Layer 4: The TCP handshake with the client failed.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** HTTP 502 is an Application Layer error. It indicates that Nginx (acting as a gateway/proxy) tried to talk to the backend, but the backend "dropped the ball" (returned a malformed response or closed the connection).
**Certification Alignment:** AWS Certified SysOps Administrator (Troubleshooting ELB)
</details>

**Scenario 14: The Large Payload Timeout**
A file upload service works for small 1KB files but hangs and times out for 100MB files. You suspect an MTU mismatch in a GRE tunnel.
**Question:** Which layer/service handles the breaking of these large messages into segments?
- A) Layer 2 (Framing)
- B) Layer 4 (Segmentation & Reassembly)
- C) Layer 3 (Routing)
- D) Layer 7 (Application logic)

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The Transport Layer (TCP) is responsible for breaking application data into segments that fit within the Maximum Transmission Unit (MTU) of the underlying network.
**Certification Alignment:** CompTIA Network+ / CCNA (TCP Fundamentals)
</details>

**Scenario 15: "Sticky" Session failure**
A user logs into your application, but every time they click a new page, they are asked to log in again. You have 3 backend servers behind a Load Balancer.
**Question:** Which OSI Layer 5 concept is failing, and how do Load Balancers typically solve it?
- A) Data encryption; using better ciphers.
- B) Session Management; using "Sticky Sessions" or "Session Affinity."
- C) Path Determination; using better routing protocols.
- D) Framing; by increasing the MTU.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Session management ensures that a user is "sticky" to the same server where their login state is stored. If the LB sends them to a different server, that server doesn't know who they are.
**Certification Alignment:** AWS Certified Solutions Architect Associate (ELB Configuration)
</details>

---

## 🏁 Part 4: Mixed Scenarios

**Scenario 16: Telnet vs Curl**
You want to check if a remote server is accepting connections on port 3306 (MySQL), but you don't have the MySQL client installed.
**Question:** Which simple tool can you use to test if the "pipe" is open?
- A) `telnet <IP> 3306` (or `nc -zv <IP> 3306`)
- B) `ping <IP>`
- C) `ip link`
- D) `arp -a`

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** `telnet` and `netcat` (`nc`) are versatile tools that can initiate a raw TCP connection to any port, making them perfect for "checking the pipe" without needing application-specific clients.
**Certification Alignment:** CompTIA Linux+ / LPIC-1
</details>

**Scenario 17: VLAN Hopping Prevention**
You want to ensure that the "Finance" department cannot talk to the "Guest" Wi-Fi users at all, even though they are plugged into the same physical switch.
**Question:** Which Layer 2 technology do you use?
- A) Subnetting
- B) VLANs (Virtual LANs)
- C) Proxy Servers
- D) DNS Filtering

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** VLANs allow you to logically segment a single physical switch into multiple virtual networks, ensuring traffic isolation at Layer 2.
**Certification Alignment:** CompTIA Network+ / CCNA
</details>

**Scenario 18: ICMP Disabled**
A server is definitely running and responding to web requests, but `ping <IP>` returns "Request Timed Out."
**Question:** Why is this happening?
- A) The server is down.
- B) The server or a firewall is blocking ICMP (Internet Control Message Protocol) traffic.
- C) The server has no IP address.
- D) Pinging only works on local networks.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Many administrators block ICMP (the protocol used by `ping`) as a hardening measure to prevent network mapping. This is called "Security by Obscurity."
**Certification Alignment:** CompTIA Security+ / AWS Certified Security Specialty
</details>

**Scenario 19: Public vs Private IP**
An instance in a cloud provider has a Private IP of `10.0.1.5` and a Public IP of `54.12.33.4`. You want to allow another instance *in the same VPC* to connect to it.
**Question:** Which IP should you use for the internal connection to reduce costs and improve speed?
- A) The Public IP.
- B) The Private IP.
- C) It doesn't matter.
- D) Use the MAC address instead.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Using private IPs keeps traffic within the cloud provider's backbone, which is faster, free (usually), and more secure than sending it over the public internet.
**Certification Alignment:** AWS Certified Cloud Practitioner / Solutions Architect Associate
</details>

**Scenario 20: The "Broken" Website**
You change the DNS record for `test.com` to a new IP, but you still see the old website when you visit it.
**Question:** What is the most likely reason?
- A) The server is too slow.
- B) DNS Caching (TTL - Time To Live) hasn't expired yet.
- C) The website is deleted.
- D) The new IP is incorrect.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** DNS settings are cached by browsers and ISPs for a period of time defined by the TTL. Changes won't be visible globally until the old cache entries expire.
**Certification Alignment:** CompTIA Network+ / AWS Certified Solutions Architect (Route 53)
</details>

---

## 🗝️ Answer Key (Summary)
1. B | 2. B | 3. B | 4. A | 5. B  
6. B | 7. C | 8. B | 9. B | 10. C  
11. B | 12. C | 13. B | 14. B | 15. B  
16. A | 17. B | 18. B | 19. B | 20. B
