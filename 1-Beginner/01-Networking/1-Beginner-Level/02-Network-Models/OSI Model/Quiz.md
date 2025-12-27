# 🧠 Network Model Quiz

Test your knowledge of the OSI and TCP/IP models with these 20 questions.

## Part 1: OSI Model Layers

**1. Which layer of the OSI model is responsible for logical addressing and routing?**
- A) Layer 2 (Data Link)
- B) Layer 3 (Network)
- C) Layer 4 (Transport)
- D) Layer 7 (Application)

**2. Which device operates primarily at the Data Link Layer (Layer 2)?**
- A) Router
- B) Switch
- C) Hub
- D) Repeater

**3. What is the Protocol Data Unit (PDU) for the Transport Layer?**
- A) Packet
- B) Frame
- C) Segment
- D) Bit

**4. HTTP, FTP, and DNS operate at which layer of the OSI model?**
- A) Session
- B) Presentation
- C) Application
- D) Transport

**5. Which layer ensures reliable end-to-end data delivery and flow control?**
- A) Network
- B) Transport
- C) Data Link
- D) Session

**6. MAC addresses are physical addresses used at which layer?**
- A) Layer 1
- B) Layer 2
- C) Layer 3
- D) Layer 4

**7. Which layer translates data formats (encryption, compression) for the application?**
- A) Application
- B) Presentation
- C) Session
- D) Transport

**8. Cables and radio waves belong to which layer?**
- A) Physical
- B) Data Link
- C) Network
- D) Transport

**9. What device operates at Layer 3 to connect different networks?**
- A) Switch
- B) Bridge
- C) Router
- D) Hub

**10. Which layer manages sessions between applications?**
- A) Transport
- B) Session
- C) Presentation
- D) Application

## Part 2: TCP/IP & Practical Scenarios

**11. The TCP/IP "Internet" layer corresponds to which OSI layer?**
- A) Data Link
- B) Network
- C) Transport
- D) Session

**12. When you type `google.com` in your browser, which protocol resolves the name to an IP?**
- A) HTTP
- B) TCP
- C) DNS
- D) ARP

**13. Which protocol is connectionless and does not guarantee delivery?**
- A) TCP
- B) UDP
- C) HTTP
- D) FTP

**14. A firewall blocking port 80 is filtering traffic at which OSI layer?**
- A) Layer 2
- B) Layer 3
- C) Layer 4
- D) Layer 7

**15. "Encapsulation" refers to:**
- A) Compressing data for storage
- B) Adding headers/trailers as data moves down the stack
- C) Encrypting data for security
- D) Routing packets across the internet

**16. Which command would you use to trace the path to a server (Layer 3 troubleshooting)?**
- A) `ping`
- B) `traceroute` (or `tracert`)
- C) `netstat`
- D) `nslookup`

**17. If a server is reachable via IP but not by hostname, the issue is likely at which layer?**
- A) Layer 1 (Physical)
- B) Layer 3 (Network)
- C) Layer 7 (Application/DNS)
- D) Layer 2 (Data Link)

**18. Security Groups in AWS act as a virtual firewall at the instance level. They control traffic primarily based on:**
- A) Content of the packet (Layer 7)
- B) Ports and Protocols (Layer 4)
- C) MAC Addresses (Layer 2)
- D) User Identity (Layer 7)

**19. What protocol connects a MAC address to an IP address?**
- A) DNS
- B) DHCP
- C) ARP
- D) ICMP

**20. A "Load Balancer" often decrypts SSL traffic. At which layer does this decryption happen?**
- A) Network
- B) Transport
- C) Presentation (technically) / Application
- D) Physical

---

## ✅ Answers

1. **B** (Network)
2. **B** (Switch)
3. **C** (Segment)
4. **C** (Application)
5. **B** (Transport)
6. **B** (Layer 2)
7. **B** (Presentation)
8. **A** (Physical)
9. **C** (Router)
10. **B** (Session)
11. **B** (Network)
12. **C** (DNS)
13. **B** (UDP)
14. **C** (Layer 4 - Transport/Ports)
15. **B**
16. **B** (Traceroute)
17. **C** (DNS issue)
18. **B** (Layer 4)
19. **C** (ARP)
20. **C** (Presentation/Application)
