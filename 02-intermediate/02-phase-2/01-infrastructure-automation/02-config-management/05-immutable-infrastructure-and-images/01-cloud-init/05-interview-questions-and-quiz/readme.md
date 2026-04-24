# Cloud-Init Interview Questions & Quiz

## 🎤 Interview Questions

### **Technical Questions**

1. **Explain the five stages of Cloud-Init boot process and what happens in each stage.**
   - *Answer*: Generator (determines data sources), Local (processes local data before networking), Network (configures networking and processes remote data), Config (runs user configuration modules), Final (executes final tasks and scripts).

2. **What are the different data sources Cloud-Init can use to retrieve configuration?**
   - *Answer*: Metadata service (cloud provider endpoints), User data (configuration passed at launch), Vendor data (cloud provider specific), Local files (configuration files on instance), and Network data sources.

3. **How does Cloud-Init handle network configuration across different cloud providers?**
   - *Answer*: Cloud-Init uses a standardized network configuration format (Netplan v2) that gets translated to provider-specific implementations. It supports static IP, DHCP, bonding, VLANs, and bridges.

4. **What is the difference between cloud-config and shell scripts in user data?**
   - *Answer*: Cloud-config is declarative YAML format for system configuration, while shell scripts are imperative commands. Cloud-config is idempotent and handles dependencies, while shell scripts run sequentially and may not be idempotent.

---

## 🧠 Cloud-Init Knowledge Quiz (25 Questions)

**1. What is the primary purpose of Cloud-Init?**
- A) Container orchestration
- B) Cloud instance initialization and configuration
- C) Network monitoring
- D) Database management

<details>
<summary>Show Answer</summary>
Answer: B) Cloud instance initialization and configuration
</details>

**2. Which stage of Cloud-Init runs before networking is configured?**
- A) Generator stage
- B) Local stage
- C) Network stage
- D) Config stage

<details>
<summary>Show Answer</summary>
Answer: B) Local stage
</details>

**3. What file format is primarily used for cloud-config?**
- A) JSON
- B) XML
- C) YAML
- D) TOML

<details>
<summary>Show Answer</summary>
Answer: C) YAML
</details>

**4. How do you install packages using cloud-config?**
- A) install_packages: [nginx, git]
- B) packages: [nginx, git]
- C) apt_packages: [nginx, git]
- D) software: [nginx, git]

<details>
<summary>Show Answer</summary>
Answer: B) packages: [nginx, git]
</details>

**5. What directive is used to create files in cloud-config?**
- A) create_files
- B) write_files
- C) make_files
- D) file_content

<details>
<summary>Show Answer</summary>
Answer: B) write_files
</details>

**6. How do you run commands in cloud-config?**
- A) commands
- B) execute
- C) runcmd
- D) shell

<details>
<summary>Show Answer</summary>
Answer: C) runcmd
</details>

**7. How do you disable password authentication for SSH?**
- A) ssh_pwauth: false
- B) ssh_password: disabled
- C) password_auth: no
- D) ssh_auth: key-only

<details>
<summary>Show Answer</summary>
Answer: A) ssh_pwauth: false
</details>

**8. What directive updates the package database?**
- A) update_packages: true
- B) package_update: true
- C) apt_update: true
- D) system_update: true

<details>
<summary>Show Answer</summary>
Answer: B) package_update: true
</details>

**9. How do you set the system timezone?**
- A) timezone: UTC
- B) system_timezone: UTC
- C) time_zone: UTC
- D) tz: UTC

<details>
<summary>Show Answer</summary>
Answer: A) timezone: UTC
</details>

**10. What is used to configure network interfaces?**
- A) networking
- B) network
- C) interfaces
- D) netconfig

<details>
<summary>Show Answer</summary>
Answer: B) network
</details>

**11. How do you include external configuration files?**
- A) #include
- B) #import
- C) #load
- D) #source

<details>
<summary>Show Answer</summary>
Answer: A) #include
</details>

**12. Which command validates cloud-config syntax?**
- A) cloud-init validate
- B) cloud-init check
- C) cloud-init schema
- D) cloud-init verify

<details>
<summary>Show Answer</summary>
Answer: C) cloud-init schema
</details>

**13. How do you configure a static IP address?**
- A) In the network section with dhcp4: false and addresses
- B) Using static_ip directive
- C) In the interfaces section
- D) Using ip_config directive

<details>
<summary>Show Answer</summary>
Answer: A) In the network section with dhcp4: false and addresses
</details>

**14. How do you reboot the system after configuration?**
- A) reboot: true
- B) power_state: mode: reboot
- C) system_reboot: true
- D) restart: true

<details>
<summary>Show Answer</summary>
Answer: B) power_state: mode: reboot
</details>

**15. How do you disable the root user?**
- A) disable_root: true
- B) root_disabled: true
- C) no_root: true
- D) root_access: false

<details>
<summary>Show Answer</summary>
Answer: A) disable_root: true
</details>

---

## 🏗️ Real-Life Scenarios

### **Scenario 1: Web Server Auto-Scaling**
**Problem**: Configure identical web servers in an auto-scaling group.
**Solution**: Use cloud-config with package installation, SSL setup, and monitoring.

### **Scenario 2: Security Compliance**
**Problem**: Implement security hardening across all instances.
**Solution**: Use cloud-config for SSH keys, firewall rules, and security tools.

### **Scenario 3: Development Environment**
**Problem**: Standardize developer environments.
**Solution**: Create cloud-config templates with development tools and settings.

---

**Assessment**: 12-15 correct = Expert, 9-11 = Advanced, 6-8 = Intermediate, <6 = Beginner