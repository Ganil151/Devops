# Beginner Level: DevOps Foundation Quizzes

👉 **[Back to main Quiz Hub](../README.md)**

Test your knowledge on the fundamental concepts of DevOps.

## Module 01: Networking Foundations
**Study Resource**: [Networking Basics](../../01-beginner/01-phase-1/01-networking/readme.md)

1. Which layer of the OSI model is responsible for IP addressing and routing?
- A) Layer 2 (Data Link)
- B) Layer 3 (Network)
- C) Layer 4 (Transport)
- D) Layer 7 (Application)

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Layer 3 (Network Layer) handles logical addressing (IP addresses) and routing decisions to move packets between different networks.
**Certification Alignment:** CompTIA Network+ / AWS Certified Cloud Practitioner
</details>

2. What is the default port for HTTPS traffic?
- A) 80
- B) 22
- C) 443
- D) 53

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** HTTPS (Hypertext Transfer Protocol Secure) uses port 443 by default. Port 80 is used for standard HTTP.
**Certification Alignment:** CompTIA Network+ / AWS Certified Cloud Practitioner
</details>

3. Which command is used to test the reachability of a host on an IP network?
- A) ping
- B) traceroute
- C) netstat
- D) curl

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** `ping` uses ICMP Echo Request/Reply packets to test reachability and measure round-trip time.
**Certification Alignment:** CompTIA Network+ / AWS Certified Cloud Practitioner
</details>

4. What does DNS stand for?
- A) Domain Name System
- B) Digital Network System
- C) Data Node Server
- D) Distributed Network Service

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** DNS (Domain Name System) translates human-readable domain names (like google.com) into IP addresses (like [IP_ADDRESS]) that computers use to identify each other.
**Certification Alignment:** CompTIA Network+ / AWS Certified Cloud Practitioner
</details>

5. Which tool is used for GUI-based deep packet inspection and protocol analysis?
- A) Nmap
- B) Wireshark
- C) Tcpdump
- D) Traceroute

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Wireshark is the industry standard for protocol analysis with a graphical user interface, allowing for deep inspection of hundreds of protocols.
**Certification Alignment:** CompTIA Network+ / Wireshark Certified Network Analyst
</details>

6. Which Nmap flag is used to identify the version of active services?
- A) -sS
- B) -sV
- C) -p
- D) -sn

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The `-sV` flag stands for Service Version detection. It probes open ports to determine what service is running and its version.
**Certification Alignment:** CompTIA Security+ / AWS Certified Security Specialty
</details>

7. What is the primary advantage of using `tcpdump` over Wireshark?
- A) It has a better GUI
- B) It is faster for small captures
- C) It can be run on remote servers via CLI without a desktop environment
- D) It doesn't require root privileges

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** `tcpdump` is a powerful command-line tool, making it ideal for troubleshooting on remote servers, headless systems, or within containers where a GUI is unavailable.
**Certification Alignment:** CompTIA Security+ / LPIC-1
</details>

---

## Module 02: Linux & Operating Systems
**Study Resource**: [Linux Basics](../../readme.md)

1. Which command is used to list files in a directory in Linux?
- A) cd
- B) ls
- C) mkdir
- D) touched

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The `ls` command (list) is used to display the files and directories within a given path.
**Certification Alignment:** CompTIA Linux+ / LPIC-1
</details>

2. In Linux, what does the command `chmod 777 file.txt` do?
- A) Deletes the file
- B) Gives full read, write, and execute permissions to everyone
- C) Makes the file read-only
- D) Changes the owner of the file

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** `7` in octal represents `rwx` (read, write, execute). `777` grants these permissions to the Owner, Group, and Others. While often used for testing, it is a security risk in production.
**Certification Alignment:** CompTIA Linux+ / LPIC-1
</details>

---

## Module 03: SSH & Remote Access
**Study Resource**: [SSH Guide](../../readme.md)

1. Which file on the REMOTE server stores the public keys of authorized users?
- A) ~/.ssh/id_rsa.pub
- B) ~/.ssh/authorized_keys
- C) /etc/ssh/sshd_config
- D) ~/.ssh/known_hosts

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The `authorized_keys` file contains the public keys of clients who are allowed to log in to that specific user account via SSH.
**Certification Alignment:** CompTIA Linux+ / AWS Certified SysOps Administrator
</details>

2. Why is **Key-Based Authentication** considered more secure than password authentication for SSH?
- A) Keys are shorter than passwords
- B) Keys are harder to brute-force and cannot be easily guessed
- C) Passwords are encrypted; keys are not
- D) Keys only work on Windows

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** SSH keys use robust cryptographic algorithms and are practically impossible to brute-force compared to traditional passwords, which are often reused or weak.
**Certification Alignment:** CompTIA Security+ / AWS Certified Security Specialty
</details>

---

## Module 04: Version Control (Git)
**Study Resource**: [Git Fundamentals](../../readme.md)

1. Which tool is commonly used for version control in DevOps?
- A) Git
- B) Jenkins
- C) Docker
- D) Kubernetes

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** Git is the most widely used distributed version control system, essential for tracking changes in code and collaborating in DevOps teams.
**Certification Alignment:** GitHub Foundations / AWS Certified DevOps Engineer
</details>

2. What is the state of a file after you run `git add <file>` but before you run `git commit`?
- A) Modified
- B) Staged (Index)
- C) Untracked
- D) Committed

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** `git add` moves changes to the Staging Area (the Index), signifying they are prepared to be included in the next commit.
**Certification Alignment:** GitHub Foundations / AWS Certified DevOps Engineer
</details>

---

## Module 05: Data Formats (YAML & JSON)
**Study Resource**: [Data Formats](../../readme.md)

1. In YAML, how are lists (arrays) represented?
- A) Using curly braces `{}`
- B) Using square brackets `[]` or a dash `-` at the start of each item
- C) Using parentheses `()`
- D) YAML does not support lists

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** YAML supports both inline lists `[item1, item2]` and block-style lists using the hyphen/dash `-` syntax.
**Certification Alignment:** CKA (Certified Kubernetes Administrator) / AWS Certified SysOps
</details>

2. Which of the following is a valid JSON fragment?
- A) `{ name: "DevOps" }`
- B) `{ "name": "DevOps" }`
- C) `name = "DevOps"`
- D) `<name>DevOps</name>`

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** In JSON, keys must be double-quoted strings. Option A is missing quotes on the key, C is assignment syntax, and D is XML.
**Certification Alignment:** AWS Certified Developer Associate
</details>

---

## Module 06: Docker Basics
**Study Resource**: [Docker Basics](../../readme.md)

1. What is a container in DevOps?
- A) A virtual machine
- B) A type of cloud service
- C) A lightweight, portable unit for running applications
- D) A database storage unit

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Containers provide OS-level virtualization, allowing applications and their dependencies to run consistently across any environment without the overhead of a full Virtual Machine.
**Certification Alignment:** Docker Certified Associate / CKA
</details>

2. Which command stops a Docker container?
- A) docker run
- B) docker build
- C) docker ps
- D) docker stop

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** D
**Why?** `docker stop` sends a SIGTERM signal to the container, allowing it to shut down gracefully before being terminated.
**Certification Alignment:** Docker Certified Associate / CKA
</details>

---

## Module 07: Maven & Build Tools
**Study Resource**: [Maven Basics](../../readme.md)

1. Which file is the primary configuration file for a Maven project?
- A) package.json
- B) pom.xml
- C) build.gradle
- D) maven.config

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The Project Object Model (POM) file (`pom.xml`) is the heart of a Maven project, containing configuration, dependencies, and build plugins.
**Certification Alignment:** AWS Certified Developer Associate / Oracle Certified Professional (Java)
</details>

2. In which Maven phase are unit tests typically executed?
- A) compile
- B) package
- C) test
- D) install

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Maven has a standard lifecycle. The `test` phase specifically triggers the execution of unit tests using frameworks like JUnit or TestNG.
**Certification Alignment:** AWS Certified DevOps Engineer Professional
</details>

---

## Module 08: Basic CI/CD
**Study Resource**: [CI/CD Basics](../../readme.md)

1. What does CI/CD stand for?
- A) Continuous Integration/Continuous Delivery
- B) Code Integration/Code Deployment
- C) Continuous Integration/Continuous Deployment
- D) Both A and C are common

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** D
**Why?** CI always stands for Continuous Integration. CD can stand for Continuous Delivery (manual gate to prod) or Continuous Deployment (automated to prod), depending on the automation level.
**Certification Alignment:** AWS Certified DevOps Engineer Professional
</details>

2. What is a "Build Artifact"?
- A) An ancient piece of code no one understands
- B) The final packaged version of your app (e.g., .jar, .zip)
- C) A bug that has been in the system for years
- D) A temporary log file

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** An artifact is the output of a build process—a deployable unit like a JAR file, WAR file, or Docker image that is eventually moved to an artifact repository.
**Certification Alignment:** AWS Certified DevOps Engineer Professional
</details>

---

## Module 09: Cloud Foundations
**Study Resource**: [Cloud Foundations](../../readme.md)

1. What is the fundamental security principle of "Least Privilege"?
- A) Giving users access to everything by default
- B) Giving users only the minimum permissions they need
- C) Granting admin rights to all developers
- D) Limiting the number of users

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Least Privilege ensures that users and applications have only the necessary permissions required to perform their tasks, minimizing the potential impact of a security breach.
**Certification Alignment:** AWS Certified Cloud Practitioner / CompTIA Security+
</details>

2. In cloud IAM, what is the main difference between a User and a Role?
- A) A user has long-term credentials; a role is assumed temporarily
- B) Roles are only for hardware; users are for people
- C) Users are free; roles require a subscription
- D) There is no difference

<details>
<summary>Click to Reveal Answer**Correct Answer:** A
**Why?** Users represent people or applications with permanent access keys or passwords. Roles are identities that can be assumed by users or services to gain temporary, cross-account, or service-level permissions.
**Certification Alignment:** AWS Certified Solutions Architect Associate
</details>

---

## Module 10: DevOps Overview
**Study Resource**: [DevOps Overview](../../readme.md)

1. What does DevOps stand for?
- A) Development and Operations
- B) Development, Operations, and Software
- C) Deploying Operations Systems
- D) Digital Operations Strategy

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** DevOps is a cultural and professional movement that stresses communication, collaboration, and integration between software developers and IT operations professionals.
**Certification Alignment:** DevOps Institute Foundation
</details>

2. What is the "shift-left" approach in DevOps?
- A) Integrating security early in the development cycle
- B) Moving operations to the left side of the pipeline
- C) Delaying testing
- D) Focusing on deployment only

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** Shifting left means performing tasks like testing, security audits, and deployment preparation earlier in the SDLC to catch issues before they reach production.
**Certification Alignment:** AWS Certified DevOps Engineer Professional
</details>

---

## 🏗️ Real-World Scenarios (Beginner)

**Scenario S1: The "It Works on My Machine" Problem**
Question: Which DevOps tool/concept best solves this consistency problem?
- A) Git
- B) Docker (Containerization)
- C) SSH
- D) Manual Documentation

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Docker packages the application with all its environmental dependencies (OS, libraries, config), ensuring it runs the exact same way on a laptop, a build server, and in the cloud.
**Certification Alignment:** Docker Certified Associate
</details>

**Scenario S2: S3 "Access Denied"**
Question: Why can't the intern upload the file?
- A) Because they aren't using a VPN
- B) Because in cloud environments, no permissions are granted until explicitly allowed by a policy
- C) Because the storage bucket is full
- D) Because the intern doesn't have an email address

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Most cloud providers follow a "Deny by Default" security model. Unless there is an explicit "Allow" policy attached to the user or bucket, the request will be denied.
**Certification Alignment:** AWS Certified Cloud Practitioner
</details>

**Scenario S3: The "Connection Refused" Mystery**
Question: What is the first thing a DevOps engineer should check?
- A) The VM's CPU usage
- B) The Security Group / Firewall rules for inbound traffic
- C) The DNS registration of the domain
- D) The Docker version on the VM

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** "Connection Refused" usually indicates that the destination port is not reachable or the service is not listening. Checking the firewall/Security Group to see if the port is open is the critical first step.
**Certification Alignment:** AWS Certified Solutions Architect Associate
</details>

---

## Answer Key (Summary)
1. B | 2. C | 3. A | 4. A | 5. B | 6. B | 7. C
Linux: 1. B | 2. B
SSH: 1. B | 2. B
Git: 1. A | 2. B
Data: 1. B | 2. B
Docker: 1. C | 2. D
Maven: 1. B | 2. C
CI/CD: 1. D | 2. B
Cloud: 1. B | 2. A
DevOps: 1. A | 2. A
Scenarios: S1. B | S2. B | S3. B

---

### 🚀 Level Up your Troubleshooting!
Ready for a bigger challenge? Try our **[Advanced Networking Scenarios Quiz](./networking-scenarios.md)** with 20+ real-world DevOps networking problems!