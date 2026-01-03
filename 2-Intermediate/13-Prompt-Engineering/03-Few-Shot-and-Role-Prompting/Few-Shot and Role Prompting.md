At the intermediate level, we move beyond "Zero-Shot" (single question) to more controlled and reliable techniques.

## 🎭 Role-Based Prompting
Assigning a specific persona to the AI narrows its probability space to the relevant domain knowledge.

| Persona | Context | Use Case |
| :--- | :--- | :--- |
| **Security Auditor** | Compliance & Hardening | Reviewing Terraform plans for public S3 buckets. |
| **Golang Developer** | Application Logic | Writing a custom Prometheus exporter. |
| **Technical Writer** | Documentation | Refining a README for a legacy Python script. |
| **AWS Solutions Architect** | Infrastructure | Designing a Multi-Region failover architecture. |

---

## 📋 Few-Shot Prompting
Few-shot prompting involves providing the model with a few examples of the desired input/output format before asking the final task. This is the most effective way to ensure consistent code/config generation.
### Example: Generating Ansible Tasks
> "Task: Generate Ansible tasks to install and configure Nginx.
> **Example 1**:
> Input: Install Apache
> Output: 
> - name: Install Apache
>   apt: name=apache2 state=present
>
> **Example 2**:
> Input: Restart SSH
> Output:
> - name: Restart ssh
>   service: name=ssh state=restarted
>
> **Actual Task**:
> Input: [Insert your request here]"

---

## 🛡️ "Act as a Pen-Tester" for Security
Role-based prompting is highly effective for security reviews. By asking the AI to "Think like an attacker," you can uncover vulnerabilities in your IaC that traditional linters might miss.
