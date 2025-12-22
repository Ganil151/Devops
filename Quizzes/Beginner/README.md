# Beginner Level: DevOps Foundation Quizzes

Test your knowledge on the fundamental concepts of DevOps.

## Module 01: DevOps Basics
**Study Resource**: [DevOps Overview](../../README.md)

1. What does DevOps stand for?
- A) Development and Operations
- B) Development, Operations, and Software
- C) Deploying Operations Systems
- D) Digital Operations Strategy

2. What is the primary goal of DevOps?
- A) To improve collaboration between development and operations teams
- B) To reduce the number of developers
- C) To automate only testing processes
- D) To focus solely on hardware management

3. Which of the following is a key principle of DevOps?
- A) Siloed teams
- B) Continuous improvement
- C) Manual deployments only
- D) Avoiding automation

4. What is the "shift-left" approach in DevOps?
- A) Integrating security early in the development cycle
- B) Moving operations to the left side of the pipeline
- C) Delaying testing
- D) Focusing on deployment only

---

## Module 02: Version Control (Git)
**Study Resource**: [Git & GitHub Foundations](../../1-Beginner/01-Git-GitHub/README.md)

5. Which tool is commonly used for version control in DevOps?
- A) Git
- B) Jenkins
- C) Docker
- D) Kubernetes

6. What is the purpose of a webhook in DevOps?
- A) To store secrets
- B) To trigger actions on events, like CI builds
- C) To manage users
- D) To provision resources

---

## Module 03: Linux & Operating Systems
**Study Resource**: [Linux Basics](../../1-Beginner/02-Linux-Basics/README.md)

7. Which protocol is commonly used for secure communication in DevOps tools?
- A) SSH
- B) HTTP
- C) FTP
- D) Telnet

8. What command is used to list files in a directory in Linux?
- A) cd
- B) ls
- C) mkdir
- D) touched

---

## Module 04: Docker Fundamentals
**Study Resource**: [Docker Core](../../1-Beginner/03-Docker/README.md)

9. What is a container in DevOps?
- A) A virtual machine
- B) A type of cloud service
- C) A lightweight, portable unit for running applications
- D) A database storage unit

10. Which command stops a Docker container?
- A) docker run
- B) docker build
- C) docker ps
- D) docker stop

11. What does the command 'docker build' do?
- A) Runs a container
- B) Builds a Docker image
- C) Pushes an image to a registry
- D) Stops a container

12. What is the command to push a Docker image to a registry?
- A) docker run
- B) docker build
- C) docker pull
- D) docker push

---

## Module 05: Networking & CI/CD Basics
**Study Resource**: [Networking](../../1-Beginner/05-Networking/README.md) & [CI/CD Basics](../../1-Beginner/04-Basic-CI-CD/README.md)

13. What does CI/CD stand for in DevOps?
- A) Continuous Integration/Continuous Delivery
- B) Code Integration/Code Deployment
- C) Continuous Integration/Continuous Deployment
- D) Continuous Improvement/Continuous Development

14. Which tool is primarily used for Continuous Integration at a beginner level?
- A) Docker
- B) Ansible
- C) Terraform
- D) Jenkins

15. What is the purpose of a CI/CD pipeline?
- A) To manually test code
- B) To store code versions
- C) To provision hardware
- D) To automate build, test, and deployment

16. Which Git command is used to switch to a different branch?
- A) git commit
- B) git status
- C) git checkout
- D) git init

17. In Linux, what does the command `chmod 777 file.txt` do?
- A) Deletes the file
- B) Gives full read, write, and execute permissions to everyone
- C) Makes the file read-only
- D) Changes the owner of the file

18. What is a Docker 'Image' compared to a 'Container'?
- A) They are the same thing
- B) An image is a running instance of a container
- C) An image is a static template; a container is a running instance
- D) A container is used for storage, an image for networking

19. Which port is typically used for SSH by default?
- A) 80
- B) 443
- C) 22
- D) 8080

20. What is the difference between a Public and Private IP address in a basic network?
- A) Public is for the internet, Private is for local local networks
- B) Private is faster than Public
- C) Public IPs are only for servers
- D) There is no difference

---

## 🏗️ Real-World Scenarios (Beginner)

**Scenario S1: The "It Works on My Machine" Problem**
A developer says their new feature works perfectly on their laptop, but it fails when deployed to the testing server because the server is missing a specific library. 
**Question**: Which DevOps tool/concept best solves this consistency problem?
- A) Git
- B) Docker (Containerization)
- C) SSH
- D) Manual Documentation

**Scenario S2: The "Accidental Deletion"**
You are working on a collaborative project and accidentally deleted a critical configuration file on your local machine. You haven't pushed your latest changes yet, but the file was part of previous commits.
**Question**: Which Git command allows you to restore that specific file from the last commit?
- A) git init
- B) git status
- C) git checkout -- <filename>
- D) git push

**Scenario S3: The "Slow Release"**
Your team takes 2 days to manually test and deploy a new version of your web app every time a small bug is fixed. The management wants updates to be faster and less error-prone.
**Question**: What should the team implement to automate this process?
- A) A better SSH key management system
- B) A CI/CD Pipeline
- C) More Linux servers
- D) A private Docker registry

---

## Answer Key
1. A
2. A
3. B
4. A
5. A
6. B
7. A
8. B
9. C
10. D
11. B
12. D
13. A/C (Both are commonly accepted)
14. D
15. D
16. C
17. B
18. C
19. C
20. A

**Scenarios:**
S1. B
S2. C
S3. B
