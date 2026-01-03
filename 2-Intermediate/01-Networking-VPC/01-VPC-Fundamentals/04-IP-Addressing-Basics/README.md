# IP Addressing Basics

Understanding IP addressing is fundamental to VPC design and troubleshooting.

## IPv4 Address Structure

An IPv4 address is a 32-bit number written in dotted-decimal notation.

### Example: 192.168.1.100
```
Binary:    11000000.10101000.00000001.01100100
Decimal:   192     .168     .1      .100
```

Each octet (8 bits) can range from 0-255.

---

## IP Address Classes (Historical)

While classful networking is obsolete, understanding it helps with CIDR:

| Class | Range | Default Mask | Use |
| :--- | :--- | :--- | :--- |
| A | 1.0.0.0 - 126.255.255.255 | /8 (255.0.0.0) | Large networks |
| B | 128.0.0.0 - 191.255.255.255 | /16 (255.255.0.0) | Medium networks |
| C | 192.0.0.0 - 223.255.255.255 | /24 (255.255.255.0) | Small networks |
| D | 224.0.0.0 - 239.255.255.255 | N/A | Multicast |
| E | 240.0.0.0 - 255.255.255.255 | N/A | Reserved |

---

## Subnet Masks

A subnet mask separates the network portion from the host portion.

### Example: 255.255.255.0 (/24)
```
IP Address:    192.168.1.100
Subnet Mask:   255.255.255.0
               11111111.11111111.11111111.00000000

Network:       192.168.1.0    (first 24 bits)
Host:          100             (last 8 bits)
```

---

## CIDR Notation Quick Reference

| CIDR | Subnet Mask | Hosts | Common Use |
| :--- | :--- | :--- | :--- |
| /32 | 255.255.255.255 | 1 | Single host |
| /31 | 255.255.255.254 | 2 | Point-to-point links |
| /30 | 255.255.255.252 | 4 | Point-to-point (with network/broadcast) |
| /29 | 255.255.255.248 | 8 | Very small subnet |
| /28 | 255.255.255.240 | 16 | NAT Gateway subnet |
| /27 | 255.255.255.224 | 32 | Small subnet |
| /26 | 255.255.255.192 | 64 | Small subnet |
| /25 | 255.255.255.128 | 128 | Medium subnet |
| /24 | 255.255.255.0 | 256 | Standard subnet |
| /23 | 255.255.254.0 | 512 | Large subnet |
| /22 | 255.255.252.0 | 1,024 | Very large subnet |
| /21 | 255.255.248.0 | 2,048 | EKS cluster |
| /20 | 255.255.240.0 | 4,096 | Very large |
| /19 | 255.255.224.0 | 8,192 | Huge |
| /18 | 255.255.192.0 | 16,384 | Massive |
| /17 | 255.255.128.0 | 32,768 | Enterprise |
| /16 | 255.255.0.0 | 65,536 | Standard VPC |

---

## Special IP Addresses

### Reserved Ranges (RFC 1918 - Private)
- **10.0.0.0/8**: 16,777,216 addresses
- **172.16.0.0/12**: 1,048,576 addresses
- **192.168.0.0/16**: 65,536 addresses

### Other Special Addresses
- **0.0.0.0/8**: Current network
- **127.0.0.0/8**: Loopback (localhost)
- **169.254.0.0/16**: Link-local (APIPA)
- **224.0.0.0/4**: Multicast
- **255.255.255.255**: Broadcast

---

## AWS Reserved IPs (Per Subnet)

In every subnet, AWS reserves 5 IP addresses:

### Example: 10.0.1.0/24
1.  **10.0.1.0**: Network address
2.  **10.0.1.1**: VPC router
<b>3. 10.0.1.2**: DNS server</b>
<details>
<summary>Show Answer</summary>
Answer: Amazon-provided
</details>

4.  **10.0.1.3**: Reserved for future use
5.  **10.0.1.255**: Broadcast address

**Usable IPs**: 256 - 5 = **251**

---

## Subnetting Practice

### Problem: Divide 10.0.0.0/16 into 4 equal subnets

**Solution**:
- Original: 10.0.0.0/16 (65,536 IPs)
- Need: 4 subnets = 2² subnets
- New prefix: /16 + 2 = /18

**Result**:
<b>1. 10.0.0.0/18</b>
<details>
<summary>Show Answer</summary>
Answer: 10.0.0.0 - 10.0.63.255
</details>

<b>2. 10.0.64.0/18</b>
<details>
<summary>Show Answer</summary>
Answer: 10.0.64.0 - 10.0.127.255
</details>

<b>3. 10.0.128.0/18</b>
<details>
<summary>Show Answer</summary>
Answer: 10.0.128.0 - 10.0.191.255
</details>

<b>4. 10.0.192.0/18</b>
<details>
<summary>Show Answer</summary>
Answer: 10.0.192.0 - 10.0.255.255
</details>


---

## IPv6 in VPCs

AWS supports IPv6 with /56 CIDR blocks:
- **Format**: 2001:0db8:1234:5678::/64
- **Size**: 18,446,744,073,709,551,616 addresses per subnet
- **Cost**: Free (no IPv6 data transfer charges within region)
- **Dual Stack**: Can run IPv4 and IPv6 simultaneously

---

## 🏗️ Real-Life Scenario: The Subnet Miscalculation
**Problem**: Team creates subnet 10.0.1.0/24 expecting 256 usable IPs.
**Reality**: Only 251 IPs available.
**Impact**: Kubernetes cluster with 252 pods fails to schedule.
**Root Cause**: Forgot about 5 AWS-reserved IPs.
**Fix**: Changed to /23 (507 usable IPs).
**Lesson**: Always account for AWS reserved IPs when sizing subnets.

---

## ❓ Interview Questions
1.  **How do you calculate the number of usable IPs in a subnet?**
    *   *Answer*: Formula: 2^(32 - prefix_length) - 5. The -5 accounts for AWS reserved IPs (network address, VPC router, DNS server, future use, broadcast address).
2.  **What is the difference between /24 and /25?**
    *   *Answer*: /24 has 256 total IPs (251 usable in AWS), while /25 has 128 total IPs (123 usable in AWS). /25 splits a /24 network in half.

---

## 🧠 Quiz Snippet (5/20+)
<b>1. How many bits in an IPv4 address?</b>
<details>
<summary>Show Answer</summary>
Answer: 32
</details>

<b>2. True/False: 192.168.1.0 is a valid host IP.</b>
<details>
<summary>Show Answer</summary>
Answer: False - it's the network address
</details>

<b>3. What is the subnet mask for /16?</b>
<details>
<summary>Show Answer</summary>
Answer: 255.255.0.0
</details>

<b>4. How many IPs does AWS reserve per subnet?</b>
<details>
<summary>Show Answer</summary>
Answer: 5
</details>

<b>5. What is the loopback address range?</b>
<details>
<summary>Show Answer</summary>
Answer: 127.0.0.0/8
</details>
