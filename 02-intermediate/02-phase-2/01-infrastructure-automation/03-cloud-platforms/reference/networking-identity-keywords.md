# 🛡️ Reference: Networking & Identity Keywords

Networking is the "Circulatory System" and Identity is the "Immune System" of the cloud. These components define how resources talk to each other and who is allowed to touch them.

---

## 🏗️ Cloud Networking

### `VPC (Virtual Private Cloud)`
*   **Definition**: A logically isolated section of the cloud where you can launch resources in a virtual network that you define.
*   **Subnets**: Divide the VPC into **Public** (has a route to an Internet Gateway) and **Private** (no direct internet access).

### `Transit Gateway`
*   **Definition**: A network transit hub that you can use to interconnect your virtual private clouds (VPCs) and on-premises networks.
*   **DevOps Why**: Simplifies network architecture by eliminating the "Full Mesh" peering nightmare as the company grows.

### `Security Groups` vs `NACLs`
*   **Security Groups**: Stateful firewalls at the **Instance** level. (Allow rules only).
*   **NACLs (Network ACLs)**: Stateless firewalls at the **Subnet** level. (Allow and Deny rules).

---

## 🔑 Identity & Access (IAM)

### `IAM Role`
*   **Definition**: An identity you can create in your account that has specific permissions. It is not associated with a specific person.
*   **Standard**: Applications should use **Roles** (identity federation/machine identity) instead of hardcoded **User Keys**.

### `Policy (JSON)`
*   **Definition**: An object that, when associated with an identity or resource, defines their permissions.
*   **Keyword: 'Principle of Least Privilege'**: Granting only the permissions required to perform a task, and nothing more.

### `SCP (Service Control Policy)`
*   **Definition**: A type of organization policy that you can use to manage permissions in your organization.
*   **DevOps Why**: Used to set "Guardrails" at the account level (e.g., "Block all users in this account from deleting S3 buckets").

---

## 🎙️ Staff Interview Context

*   **"What is the difference between an 'IAM User' and an 'IAM Role'?"**
    *   *Answer*: An **IAM User** represents a specific person or service with long-term credentials (password/secret key). An **IAM Role** is assumed for a specific duration and provides temporary credentials. Roles are significantly more secure for cross-account access and application-to-application communication.
*   **"Explain 'Stateful' vs 'Stateless' in the context of firewalls."**
    *   *Answer*: **Stateful** (Security Groups) remember the "State" of a connection. If you allow entry on port 80, the return traffic is automatically allowed. **Stateless** (NACLs) do not remember connections; you must explicitly define both the Inbound and Outbound rules.
*   **"Why would you use a 'Private Subnet' for a database?"**
    *   *Answer*: To ensure the database has no route to the internet, creating a significant barrier against external attacks. Communication should only be allowed from the web application tier via a Security Group.
*   **"What is 'Federated Identity'?"**
    *   *Answer*: Allowing users to log into the cloud using their existing corporate credentials (e.g., Okta, Active Directory, Google Workspace) via SAML or OIDC, rather than creating separate IAM users for every employee.
