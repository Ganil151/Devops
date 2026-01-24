# Cloud Networking & Security Challenges 🛡️

Secure your cloud infrastructure using advanced isolation and packet filtering.

---

## 🏆 Challenge 01: The Zero-Trust Security Group
**Objective**: Implement strictly layered inbound/outbound rules.

1.  **Scenario**: A 3-tier app (Web, App, DB).
2.  **Task**: Define security group rules for the **App SG**.
3.  **Requirements**:
    *   **Inbound**: Only allow traffic from the **Web SG** on port 8080.
    *   **Outbound**: Only allow traffic to the **Database SG** on port 5432.
4.  **Action**: Draft the Terraform or CLI commands to link the Security Groups by ID rather than IP CIDR.
5.  **Security**: Explain why linking SGs by Security Group ID is safer than using IP ranges.

---

## 🏆 Challenge 02: Private Cloud Isolation (Bastion Access)
**Objective**: Access private-subnet resources securely.

1.  **Requirement**: A Private Subnet with NO internet access (only a NAT gateway for outbound).
2.  **Task**: Deploy a **Bastion Host** in the Public Subnet.
3.  **Advanced**: Research **AWS Client VPN** or **Azure Bastion**. How do these services remove the need for managing your own EC2 jump box?
4.  **Goal**: Explain the data flow: User -> Public Bastion -> Private Instance.

---

## 🏆 Challenge 03: Cloud Audit & Compliance
**Objective**: Monitor who did what in your cloud account.

1.  **Requirement**: Enable **AWS CloudTrail** or **Azure Activity Logs**.
2.  **Task**: Intentionally delete a non-production resource.
3.  **Action**: Use the CloudTrail console to find the event.
4.  **Discovery**: Identify the **IAM User**, **Source IP**, and **Time** of the deletion.
5.  **Goal**: Draft a simple alert that triggers if an `iam:CreateUser` event occurs.

---

## 📁 Solutions
VPC security templates and CloudTrail alerting policies are in the `Boilerplates/` directory.
