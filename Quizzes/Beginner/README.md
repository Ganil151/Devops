# Beginner Level: DevOps Foundation Quizzes

Test your knowledge on the fundamental concepts of DevOps.

## Module 01: Networking Foundations
**Study Resource**: [Networking Basics](../../1-Beginner/01-Phase-1/01-Networking/README.md)

1. Which layer of the OSI model is responsible for IP addressing and routing?
- A) Layer 2 (Data Link)
- B) Layer 3 (Network)
- C) Layer 4 (Transport)
- D) Layer 7 (Application)

2. What is the default port for HTTPS traffic?
- A) 80
- B) 22
- C) 443
- D) 53

3. Which command is used to test the reachability of a host on an IP network?
- A) ping
- B) traceroute
- C) netstat
- D) curl

4. What does DNS stand for?
- A) Domain Name System
- B) Digital Network System
- C) Data Node Server
- D) Distributed Network Service

5. Which tool is used for GUI-based deep packet inspection and protocol analysis?
- A) Nmap
- B) Wireshark
- C) Tcpdump
- D) Traceroute

6. Which Nmap flag is used to identify the version of active services?
- A) -sS
- B) -sV
- C) -p
- D) -sn

7. What is the primary advantage of using `tcpdump` over Wireshark?
- A) It has a better GUI
- B) It is faster for small captures
- C) It can be run on remote servers via CLI without a desktop environment
- D) It doesn't require root privileges

---

## Module 02: Linux & Operating Systems
**Study Resource**: [Linux Basics](../../README.md)

5. Which command is used to list files in a directory in Linux?
- A) cd
- B) ls
- C) mkdir
- D) touched

6. In Linux, what does the command `chmod 777 file.txt` do?
- A) Deletes the file
- B) Gives full read, write, and execute permissions to everyone
- C) Makes the file read-only
- D) Changes the owner of the file

---

## Module 03: SSH & Remote Access
**Study Resource**: [SSH Guide](../../README.md)

7. Which file on the REMOTE server stores the public keys of authorized users?
- A) ~/.ssh/id_rsa.pub
- B) ~/.ssh/authorized_keys
- C) /etc/ssh/sshd_config
- D) ~/.ssh/known_hosts

8. Why is **Key-Based Authentication** considered more secure than password authentication for SSH?
- A) Keys are shorter than passwords
- B) Keys are harder to brute-force and cannot be easily guessed
- C) Passwords are encrypted; keys are not
- D) Keys only work on Windows

---

## Module 04: Version Control (Git)
**Study Resource**: [Git Fundamentals](../../README.md)

9. Which tool is commonly used for version control in DevOps?
- A) Git
- B) Jenkins
- C) Docker
- D) Kubernetes

10. What is the state of a file after you run `git add <file>` but before you run `git commit`?
- A) Modified
- B) Staged (Index)
- C) Untracked
- D) Committed

---

## Module 05: Data Formats (YAML & JSON)
**Study Resource**: [Data Formats](../../README.md)

11. In YAML, how are lists (arrays) represented?
- A) Using curly braces `{}`
- B) Using square brackets `[]` or a dash `-` at the start of each item
- C) Using parentheses `()`
- D) YAML does not support lists

12. Which of the following is a valid JSON fragment?
- A) `{ name: "DevOps" }`
- B) `{ "name": "DevOps" }`
- C) `name = "DevOps"`
- D) `<name>DevOps</name>`

---

## Module 06: Docker Basics
**Study Resource**: [Docker Basics](../../README.md)

13. What is a container in DevOps?
- A) A virtual machine
- B) A type of cloud service
- C) A lightweight, portable unit for running applications
- D) A database storage unit

14. Which command stops a Docker container?
- A) docker run
- B) docker build
- C) docker ps
- D) docker stop

---

## Module 07: Maven & Build Tools
**Study Resource**: [Maven Basics](../../README.md)

15. Which file is the primary configuration file for a Maven project?
- A) package.json
- B) pom.xml
- C) build.gradle
- D) maven.config

16. In which Maven phase are unit tests typically executed?
- A) compile
- B) package
- C) test
- D) install

---

## Module 08: Basic CI/CD
**Study Resource**: [CI/CD Basics](../../README.md)

17. What does CI/CD stand for?
- A) Continuous Integration/Continuous Delivery
- B) Code Integration/Code Deployment
- C) Continuous Integration/Continuous Deployment
- D) Both A and C are common

18. What is a "Build Artifact"?
- A) An ancient piece of code no one understands
- B) The final packaged version of your app (e.g., .jar, .zip)
- C) A bug that has been in the system for years
- D) A temporary log file

---

## Module 09: Cloud Foundations
**Study Resource**: [Cloud Foundations](../../README.md)

19. What is the fundamental security principle of "Least Privilege"?
- A) Giving users access to everything by default
- B) Giving users only the minimum permissions they need
- C) Granting admin rights to all developers
- D) Limiting the number of users

20. In cloud IAM, what is the main difference between a User and a Role?
- A) A user has long-term credentials; a role is assumed temporarily
- B) Roles are only for hardware; users are for people
- C) Users are free; roles require a subscription
- D) There is no difference

---

## Module 10: DevOps Overview
**Study Resource**: [DevOps Overview](../../README.md)

21. What does DevOps stand for?
- A) Development and Operations
- B) Development, Operations, and Software
- C) Deploying Operations Systems
- D) Digital Operations Strategy

22. What is the "shift-left" approach in DevOps?
- A) Integrating security early in the development cycle
- B) Moving operations to the left side of the pipeline
- C) Delaying testing
- D) Focusing on deployment only

---

## 🏗️ Real-World Scenarios (Beginner)

**Scenario S1: The "It Works on My Machine" Problem**
Question: Which DevOps tool/concept best solves this consistency problem?
- A) Git
- B) Docker (Containerization)
- C) SSH
- D) Manual Documentation

**Scenario S2: S3 "Access Denied"**
Question: Why can't the intern upload the file?
- A) Because they aren't using a VPN
- B) Because in cloud environments, no permissions are granted until explicitly allowed by a policy
- C) Because the storage bucket is full
- D) Because the intern doesn't have an email address

**Scenario S3: The "Connection Refused" Mystery**
Question: What is the first thing a DevOps engineer should check?
- A) The VM's CPU usage
- B) The Security Group / Firewall rules for inbound traffic
- C) The DNS registration of the domain
- D) The Docker version on the VM

---

## Answer Key
1. B
2. C
3. A
4. A
5. B
6. B
7. C
8. B
9. A
10. B
11. B
12. B
13. C
14. D
15. B
16. C
17. D
18. B
19. B
20. A
21. A
22. A

**Scenarios:**
S1. B
S2. B
S3. B

---

### 🚀 Level Up your Troubleshooting!
Ready for a bigger challenge? Try our **[Advanced Networking Scenarios Quiz](./Networking-Scenarios.md)** with 20+ real-world DevOps networking problems!