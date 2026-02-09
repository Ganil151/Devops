# 🖼️ Scenario & Architectural Mastery (The Whiteboard)

In architecture interviews, they aren't looking for a perfect diagram. They are looking for **Trade-off Analysis**.

---

## 🎨 The Virtual Whiteboard: How to Talk and Draw
When an interviewer says "Draw a scalable API," they are testing your ability to think out loud. Use this 4-step framework:

1.  **Clarify the Specs**: Ask "How many users?", "Is it read-heavy or write-heavy?", "What is our latency requirement?"
2.  **Breadth First**: Draw the "Happy Path" first. (Client -> Load Balancer -> Web Server -> DB).
3.  **Identify the 'Boom'**: Ask yourself "What happens when the DB hits 100% CPU?" or "What happens if a region goes dark?" and add components (Cache, SQS, Multi-Region) to fix it.
4.  **Cost vs Benefit**: Always explain your trade-offs. (e.g., "I chose DynamoDB over RDS here because we need sub-millisecond scaling and don't need complex SQL joins.")

---

## 🏗️ Scenario 1: The Global News Portal
**Prompt:** "Design a highly available web application that can handle 10 million users globally with minimal latency."

### 🧠 The Architectural Logic
1. **The Edge**: Use **Amazon CloudFront** (CDN) with S3 for static assets. This puts the data close to the user.
2. **The Compute**: Deploy an **EKS Cluster** with **Horizontal Pod Autoscaling (HPA)**.
3. **The Database**: Use **Amazon Aurora Global Database** for sub-second latency across regions.
4. **The Network**: Use **Route 53 Geolocation Routing** to send users to the nearest AWS Region.
### 🗝️ The "Interviewer's Secret" (The Twist)
**"What happens if one whole AWS Region goes down?"**
- **Senior Answer:** "My Route 53 health checks will automatically failover to the secondary region. Because I'm using Aurora Global, the secondary cluster is promoted to 'Writer' in under a minute (Low RTO/RPO)."

---

## 🏗️ Scenario 2: The E-Commerce Black Friday Spike
**Prompt:** "Your database is hitting 100% CPU during a flash sale. How do you scale it without dropping transactions?"

### 🧠 The Architectural Logic
1. **Immediate fix**: Enable **RDS Storage Autoscaling** and vertically scale the instance (requires short downtime).
2. **Better fix**: Implement **Amazon ElastiCache (Redis)** to offload frequent read queries (like product catalogs).
3. **Architectural fix**: Move to an **Asynchronous SQS Queue**. Instead of writing directly to the DB, the app puts orders on a queue. A worker process pulls them at a steady rate.

### 🗝️ The "Interviewer's Secret" (The Twist)
**"How do you ensure data consistency if the worker fails?"**
- **Senior Answer:** "I would use **SQS Dead Letter Queues (DLQ)** to capture failed messages and set up an alert to investigate why they failed, while the main queue stays healthy."

---

## 🏗️ Scenario 3: The "Zero-Trust" Compliance Migration
**Prompt:** "A bank wants to move their legacy apps to the cloud but requires that NO traffic ever touches the public internet."

### 🧠 The Architectural Logic
1. **Connectivity**: Use **AWS Direct Connect** for a private line from their data center.
2. **Isolation**: Use **VPC Endpoints (AWS PrivateLink)** so that services like S3 or DynamoDB stay on the AWS backbone and don't exit to the internet.
3. **Authentication**: Use **IAM Roles Anywhere** to give on-premises servers secure identities without fixed access keys.

### 🗝️ The "Interviewer's Secret" (The Twist)
**"How do you audit that a developer didn't accidentally add an Internet Gateway?"**
- **Senior Answer:** "I would use **AWS Config Rules** to automatically flag or delete any IGW that is created, ensuring a 'Closed Loop' security posture."

---

*This guide is part of the 08-interview-mastery module.*
