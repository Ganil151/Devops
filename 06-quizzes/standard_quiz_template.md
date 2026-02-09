### Question Template: Kubernetes Networking

**Difficulty:** [Junior | Intermediate | Senior]
**Question:** Explain how a Service selects the Pods it routes traffic to.

- [ ] A) It uses the Pod's IP address hardcoded in the YAML.
- [ ] B) It automatically detects all Pods in the same namespace.
- [x] C) It uses Label Selectors `spec.selector` to match Pod labels `metadata.labels`.
- [ ] D) It uses the Deployment name.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C

**Why?**
The mechanism is **Label Selectors**. Services are decoupled from specific Pods (which are ephemeral). By matching labels (e.g., `app: my-app`), the Service dynamically updates its Endpoint list as Pods are created or destroyed.

**Certification Alignment:** CKA (Application Lifecycle Management)
</details>

---

### Question Template: Terraform State

**Difficulty:** [Intermediate]
**Question:** What happens if two developers run `terraform apply` at the same time on the same state file?

- [ ] A) The last write wins.
- [ ] B) Terraform merges the changes automatically.
- [x] C) Without state locking, the state file can become corrupted. With locking (e.g., DynamoDB), one operation waits or fails.
- [ ] D) Terraform creates a conflict file.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C

**Why?**
Terraform state is critical for tracking infrastructure. Concurrent modifications can lead to race conditions where one process's changes are overwritten or the file becomes invalid JSON. **State Locking** prevents this by acquiring a lock before any write operation.

**Certification Alignment:** HashiCorp Certified: Terraform Associate
</details>
