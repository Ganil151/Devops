# 02 Cloud: AWS & Infrastructure Design

Mastering the high-level architecture of scalable, resilient cloud environments.

---

## ☁️ Part 1: Compute & Scaling

### [Junior] What is the difference between an ASG Launch Configuration and a Launch Template?
- [ ] A) There is no difference; they are interchangeable.
- [ ] B) Launch Configurations are newer and support more features.
- [ ] C) Launch Templates are the newer version that supports versioning, T2 Unlimited, and Spot fleets.
- [ ] D) Launch Templates only work for S3.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** AWS recommends Launch Templates (LT) over Launch Configurations. LTs allow you to store versions of your configuration, allowing for easier rollbacks and updates.
**Certification Alignment:** AWS Certified Solutions Architect Associate (SAA-C03)
</details>

---

## 💸 Part 2: FinOps & Cost Management

### [Intermediate] How does using EC2 Spot Instances affect your application's architecture?
- [ ] A) It has no effect; Spot instances are just cheaper.
- [ ] B) Your application must be stateless or able to handle a 2-minute interruption notice.
- [ ] C) Spot instances always have better performance than On-Demand.
- [ ] D) You can only use Spot for databases.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Spot instances offer up to 90% savings but can be reclaimed by AWS with a 2-minute warning. Architectures using Spot must be resilient and fault-tolerant.
**Certification Alignment:** AWS Certified SysOps Administrator (Cost Optimization)
</details>

---

## 🏆 Master Answer Key

| Question ID | Difficulty | Answer | Topic |
| :--- | :--- | :--- | :--- |
| C-01 | Junior | C | AWS Auto Scaling |
| F-01 | Intermediate | B | FinOps |
