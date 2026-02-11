# 📋 Standard DevOps Quiz Template

Use this template to create new assessment files. This ensures consistency, professional appearance, and maximum learning value.

---

### [Tier] Topic: [Specific Concept]

**Difficulty:** `[Junior | Intermediate | Senior | Staff]`  
**Domain:** `[Infrastructure | CI/CD | Security | SRE | Networking]`

**Question:** 
[Write a clear, unambiguous question. For Senior/Staff levels, focus on 'Why' or 'Trade-offs' rather than 'What'.]

- [ ] A) [Plausible Option]
- [ ] B) [Plausible Option]
- [ ] C) [Correct Option]
- [ ] D) [Distractor Option]

<details>
<summary>🔍 Click to Reveal Answer & Analysis</summary>

**Correct Answer:** [Letter]

#### 🚀 Deep Dive: The "Why"
[Provide 2-3 sentences explaining the architectural or technical reasoning. Why is this the best practice? What are the common pitfalls of the other options?]

#### 🛡️ Production Hazard
[Mention a real-world disaster or 'gotcha' related to this question. e.g., "Hardcoding this value will cause a cascading failure if the region goes down."]

#### 🎓 Certification & Industry Alignment
- **Certification**: [e.g., CKA (Cluster Architecture), AWS SAA (Resilient Architectures)]
- **Framework**: [e.g., Well-Architected Framework, SRE Handbook]
</details>

---

### Example: Staff-Level Reliability

**Difficulty:** `Staff`  
**Domain:** `Reliability / Arch`

**Question:** You are designing a global DNS-based failover strategy. Why might a low TTL (Time to Live) value (e.g., 60 seconds) be insufficient to guarantee a sub-2 minute RTO (Recovery Time Objective)?

- [ ] A) Modern browsers ignore TTLs lower than 300 seconds.
- [ ] B) TTL only applies to the root domain, not subdomains.
- [x] C) Client-side DNS caching and ISP-level recursive resolvers may disregard low TTLs to reduce traffic.
- [ ] D) Route 53 does not support TTLs below 120 seconds.

<details>
<summary>🔍 Click to Reveal Answer & Analysis</summary>

**Correct Answer:** C

#### 🚀 Deep Dive: The "Why"
While DNS is powerful, the engineer does not have total control over the **client**. ISPs and recursive resolvers often override low TTLs (caching them for longer) to improve performance and reduce overhead. Relying solely on DNS for tight RTOs is a common architectural risk.

#### 🛡️ Production Hazard
During a regional outage, even if you update your DNS records, a significant percentage of traffic may still hit the "Dead" region for several minutes (or hours in some legacy ISP cases) due to stale cache.

#### 🎓 Certification & Industry Alignment
- **Certification**: AWS Certified Solutions Architect - Professional (Network Design)
- **Framework**: Google SRE Workbook (Reliability Engineering)
</details>
