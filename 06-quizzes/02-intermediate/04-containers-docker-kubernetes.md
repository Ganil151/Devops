# 04 Containers: Docker & Kubernetes Mastery

The standard for modern application orchestration and isolation.

---

## 🐳 Part 1: Docker (Packaging)

### [Intermediate] Why is "Multi-Stage Build" considered a best practice in DevOps?
- [ ] A) It makes the build process slower but more reliable.
- [ ] B) It allows you to run containers on different CPU architectures.
- [x] C) It reduces image size and security risk by excluding build-time dependencies from the final production image.
- [ ] D) It allows you to run multiple applications in a single container.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** By using `FROM ... AS build` and then `COPY --from=build`, you can discard compilers, source code, and secrets, resulting in a lightweight, JRE-only or binary-only image.
**Certification Alignment:** Docker Certified Associate (DCA)
</details>

---

## ☸️ Part 2: Kubernetes (Orchestration)

### [Senior] How does Kubernetes handle the "Split Brain" problem in etcd?
- [ ] A) It uses a heart-beat check every 10 seconds.
- [x] B) It uses the **Raft Consensus Algorithm**, requiring a quorum (majority) to agree on any state change.
- [ ] C) It uses the Kubernetes API server as the tie-breaker.
- [ ] D) It doesn't; etcd is naturally resistant to network partitions.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Raft ensures that only one "leader" can write to the store. With an odd number of nodes (3, 5, 7), if the network splits, only the majority side can continue to function, preventing data divergence.
**Certification Alignment:** CKA (Certified Kubernetes Administrator) - High Availability
</details>

### [Junior] What is the default grace period for a pod deletion?
- [ ] A) 5 seconds
- [ ] B) 10 seconds
- [x] C) 30 seconds
- [ ] D) 60 seconds

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** This is the `terminationGracePeriodSeconds`. It gives the application a chance to catch `SIGTERM` and finish processing requests before `SIGKILL` is sent.
**Certification Alignment:** CKAD (Certified Kubernetes Application Developer)
</details>

---

## 🏆 Master Answer Key

| Question ID | Difficulty | Answer | Topic |
| :--- | :--- | :--- | :--- |
| D-01 | Intermediate | C | Multi-Stage Builds |
| K-01 | Senior | B | etcd Consensus |
| K-02 | Junior | C | Pod Lifecycle |
