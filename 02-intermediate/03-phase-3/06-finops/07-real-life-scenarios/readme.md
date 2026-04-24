# 🌍 07: FinOps in the Wild: Production Case Studies

**[⬅️ Back to Module Index](../readme.md)** | **[Advanced Track ➡️](readme.md)**

---

# 🏗️ From Bills to Unit Economics

Theory is for beginners. These scenarios describe how top-tier FinOps teams handle massive cost spikes, multi-cloud chargebacks, and the infamous "NAT Gateway" mistakes in production.

---

## 🚨 Scenario 1: The $10k GPU Ghost
**Context**: On Monday morning, the dashboard shows a $10,000 cost anomaly from the previous weekend in a "Sandbox" account.

### 🧬 The Investigative Loop:
*   **Step 1**: **Detection**. Cost Anomaly Detection flags a 500% spike in `ap-southeast-1` (Singapore).
*   **Step 2**: **Root Cause**. CloudTrail logs show a `p3.16xlarge` (GPU instance) was launched by a Data Scientist for a "quick test" but never shut down.
*   **Step 3**: **Immediate Action**. Terminate the instance and delete its 2TB ephemeral disk.

**✅ The Fix**: Implemented a **Service Control Policy (SCP)** that restricts GPU instance types to specific accounts, and a Lambda "Reaper" that kills any sandbox instance running for >8 hours.

---

## 📉 Scenario 2: The "Savings Plan" Rescue
**Context**: A company is spending $200k/month on 100% On-Demand pricing. The CFO is demanding an immediate 20% reduction.

### 🧬 The Broker's Play:
1.  **Normalization**: The team analyzes the "stable base" of usage (the minimum amount of CPU used 24/7 over the last 90 days).
2.  **Commitment**: They propose a **Compute Savings Plan** for $80/hr (covering 70% of the base).
3.  **Strategy**: They choose a "No Upfront" 1-year plan to maintain cash flow while securing a 30% discount.

**✅ The Outcome**: Monthly bill dropped by **$42,000** within 24 hours of purchase, with zero architectural changes.

---

## ☸️ Scenario 3: The Kubernetes "Black Box"
**Context**: An EKS cluster costs $15k/month, but the bill only shows one line item for "EC2 Instances." Which team is the heavy spender?

### 🧬 The Visibility Loop:
1.  **Tooling**: Installed **KubeCost** on the cluster.
2.  **Mapping**: Mapped K8s namespaces to internal `TeamID` tags.
3.  **Analysis**: Found that the "DevTools" team was requesting 16GB of RAM per pod while actually using only 512MB.

**✅ The Fix**: Set **Resource Quotas** and enforced right-sized container specs. Cluster size was reduced from 20 nodes to 8.

---

## ⚡ Scenario 4: The CEO's Challenge (Unit Economics)
**Context**: The CEO asks, "Our cloud bill went up by 15%. Are we wasting money?"

### 🧬 The Economist's Response:
1.  **Metric**: The team calculates the **Cost per Active User**.
2.  **Data**: Cloud bill went up 15%, but Active Users went up 45%.
3.  **Synthesis**: The **Cost per User actually dropped by 20%**.

**✅ The Lesson**: Total cloud cost is a "Vanity Metric." **Unit Economics** (Cost per Business Value) is the only true measure of Cloud Efficiency.

---
### 🏁 Module Complete!
You have mastered FinOps. You are now a High-Level Architect who builds for performance and profit. 
Return to the **[Phase 3 Hub](../readme.md)** to see your graduation path.
