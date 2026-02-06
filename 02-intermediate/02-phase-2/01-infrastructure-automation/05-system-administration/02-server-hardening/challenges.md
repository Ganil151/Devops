# Server Hardening Challenges 🛡️

Secure your Linux fleet against common attack vectors and unauthorized access.

---

## 🏆 Challenge 01: User Privilege Audit
**Objective**: Implementing the Principle of Least Privilege across the team.

1.  **Task**: Review the `/etc/sudoers` file.
2.  **Logic**: Remove any users with full `ALL=(ALL:ALL) ALL` access who don't strictly need it.
3.  **Requirement**: Create a new group `devops-ops` and grant them permission only to restart services (e.g., `systemctl restart *`).
4.  **Verification**: Log in as a member of `devops-ops` and try to read `/etc/shadow`. It should be **Denied**.

---

## 🏆 Challenge 02: Firewalld / Iptables Policy
**Objective**: Build a "Default Deny" network strategy.

1.  **Requirement**: Configure a Linux firewall (e.g., `ufw` or `firewalld`).
2.  **Task**: 
    *   Allow SSH (Port 22).
    *   Allow HTTP/S (80/443).
    *   **Deny** all other inbound traffic.
    *   **Advanced**: Only allow SSH from a specific subnet (your office/home CIDR).
3.  **Action**: Use `nmap` from an external machine to verify the ports are correctly filtered.

---

## 🏆 Challenge 03: File System Security (Immutable Files)
**Objective**: Prevent even the Root user from accidentally deleting critical files.

1.  **Scenario**: A malicious actor (or rogue script) tries to wipe your configuration files.
2.  **Task**: Use the `chattr` command.
3.  **Logic**: Set the `+i` (immutable) attribute on `/etc/fstab`.
4.  **Verification**: Try to edit or delete the file (even as sudo). Research how to *remove* the attribute when legitimate changes are needed.

---

## 📁 Solutions
Compliance audit scripts and Sudoers templates are in the `Boilerplates/` directory.
