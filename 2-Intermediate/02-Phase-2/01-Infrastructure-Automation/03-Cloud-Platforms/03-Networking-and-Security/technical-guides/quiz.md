# 🧠 Knowledge Check: Networking & Security Optimization

### 1. What is the main advantage of an "Interface VPC Endpoint" (PrivateLink) over a "Gateway Endpoint"?
- A) It is free of charge.
- B) It allows connectivity from on-premises via Direct Connect/VPN.
- C) It only works for S3 and DynamoDB.
- D) It uses a public IP address.

### 2. In a "Hub-and-Spoke" network architecture, what is the role of the Hub?
- A) To host all application databases.
- B) To provide a central point for shared services like inspection firewalls and VPN gateways.
- C) To connect directly to every user's personal laptop.
- D) To store all the code repositories.

### 3. Which service provides protection against DDoS attacks specifically at Layer 3 and 4?
- A) AWS WAF
- B) AWS Shield
- C) AWS Cognito
- D) AWS Secrets Manager

### 4. What is "Envelope Encryption"?
- A) Encrypting an email before sending it.
- B) Physical encryption of hard drives.
- C) Encrypting data with a data key, then encrypting the data key with a master key.
- D) Using a single key for all users.

### 5. What is the difference between a Security Group and a Network ACL?
- A) Security Group is stateless; NACL is stateful.
- B) Security Group is stateful (allows return traffic); NACL is stateless.
- C) Security Group works for the whole VPC; NACL works for a single VM.
- D) There is no difference.

### 6. When using a CDN, what is the "Origin"?
- A) The country where the user is located.
- B) The source server where the original content resides (e.g., S3 or a Web Server).
- C) The ISP of the user.
- D) The first edge location that receives traffic.

### 7. What is 'Least Privilege'?
- A) Giving everyone administrator access to save time.
- B) Granting only the minimum permissions needed to perform a specific job.
- C) Locking everyone out of the system.
- D) Only giving access to the CEO.

### 8. What does "TTL" (Time To Live) in a DNS record control?
- A) How long the server will stay online.
- B) How long a DNS resolver should cache the query results before asking again.
- C) The expiration date of the domain name.
- D) The speed of the internet connection.

### 9. Which Azure service is the direct equivalent of AWS KMS?
- A) Azure Bastion
- B) Azure Key Vault
- C) Azure Front Door
- D) Azure ExpressRoute

### 10. In GCP, what does a "Global VPC" allow you to do?
- A) Access the internet from anywhere.
- B) Connect subnets in different regions within the same VPC without peering.
- C) Bypass firewall rules.
- D) Share your network with every other GCP customer.

---

## 🔑 Answer Key
1. **B** (Interface endpoints use ENIs and are reachable via VPN/DX).
2. **B** (Centralizes management of outbound traffic and security).
3. **B** (Shield handles infrastructure-level DDoS).
4. **C** (Industry standard for secure key management).
5. **B** (SG tracks connections; NACL requires explicit inbound/outbound rules).
6. **B** (The CDN fetches content from the Origin).
7. **B** (The fundamental rule of IAM security).
8. **B** (Lower TTL allows for faster DNS changes).
9. **B** (Key Vault handles both secrets and keys).
10. **B** (GCP Networking is global by default).
