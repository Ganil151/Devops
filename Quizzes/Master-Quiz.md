# 🏆 DevOps Master Quiz

This master quiz covers essential concepts from across the entire DevOps repository, from Linux foundations to Advanced GitOps and Security.

---

## 🟢 Part 1: Beginner Level (Foundations)

**1. What is the primary purpose of a "Subnet Mask" in Networking?**
*   A) To encrypt the data being sent
*   B) To distinguish between the network portion and the host portion of an IP address
*   C) To increase the speed of the internet connection
*   D) To block unauthorized access to a server

**2. Which command is used to search for a text pattern recursively within a directory in Linux?**
*   A) `find . -name "pattern"`
*   B) `grep -r "pattern" .`
*   C) `ls -la | search "pattern"`
*   D) `cat pattern > dir`

**3. In Git, what is the safest way to undo a commit that has already been pushed to a shared remote repository?**
*   A) `git reset --hard HEAD~1`
*   B) `git delete commit`
*   C) `git revert <commit_hash>`
*   D) `git push --force`

**4. What is the primary purpose of a `.dockerignore` file?**
*   A) To list files that should be made read-only in the container
*   B) To prevent sensitive or bulky files from being included in the Docker build context
*   C) To ignore errors during the `docker build` process
*   D) To define which containers should not be started by Docker Compose

---

## 🟡 Part 2: Intermediate Level (Orchestration & IaC)

**5. In Kubernetes, which resource is responsible for ensuring a specified number of pod replicas are running at any given time?**
*   A) `Pod`
*   B) `Service`
*   C) `ReplicaSet` (usually managed by a `Deployment`)
*   D) `ConfigMap`

**6. What is the fundamental difference between Terraform and Ansible?**
*   A) Terraform is for cloud, Ansible is for on-premise
*   B) Terraform is primarily for "Infrastructure Provisioning", while Ansible is primarily for "Configuration Management"
*   C) Terraform uses YAML, while Ansible uses HCL
*   D) There is no difference; they are interchangeable

**7. Which Terraform command is used to sync the local state file with the actual resources currently deployed in the cloud?**
*   A) `terraform sync`
*   B) `terraform refresh`
*   C) `terraform update`
*   D) `terraform import`

---

## 🔴 Part 3: Advanced Level (GitOps & Security)

**8. What is the "Single Source of Truth" in a GitOps delivery model?**
*   A) The Kubernetes API Server
*   B) The CI/CD Pipeline (Jenkins/GitHub Actions)
*   C) The Git Repository
*   D) The Container Registry

**9. In DevSecOps, what does the term "Shift Left" refer to?**
*   A) Moving application logic to the front-end
*   B) Implementing security testing and audits earlier in the development lifecycle
*   C) Moving servers to a different cloud region for better latency
*   D) Using only open-source security tools

**10. What is the role of an "Admission Controller" in Kubernetes security?**
*   A) To allow users to log in to the cluster
*   B) To intercept requests to the API server and validate or mutate them before they are stored in etcd (e.g., OPA/Gatekeeper)
*   C) To manage the physical access to the data center
*   D) To pull images from private registries

---

## 🏆 Assessment Key

| Question | Answer | Category |
| :--- | :--- | :--- |
| 1 | B | Networking |
| 2 | B | Linux Basics |
| 3 | C | Git & GitHub |
| 4 | B | Docker |
| 5 | C | Kubernetes |
| 6 | B | IaC vs Config Mgmt |
| 7 | B | Terraform |
| 8 | C | GitOps |
| 9 | B | DevSecOps |
| 10 | B | K8s Security |

---

## 🔗 Next Steps
If you struggled with any section, return to the respective module:
- **[Beginner Level](../../1-Beginner/)**
- **[Intermediate Level](../../2-Intermediate/)**
- **[Advanced Level](../../3-Advanced/)**

*Congratulations on completing the Master Quiz! Continuous learning is the heart of DevOps.*
