### What is secret scanning?
Secret scanning is the practice of running automated scans on code repositories, execution pipelines, configuration files, commits, and other data sources to prevent potential security threats posed by exposed secrets. 

<font color="#ffc000">Secret scanning is part of the broader scope of secret management, which encompasses the processes and tools involved in storing and guarding secrets from unauthorized entities.</font>
### What are secrets?
Secrets are credentials used to authenticate against or get authorized access to perform sensitive actions in an enterprise’s IT systems. 

**Software projects often rely on third-party components—containers and container orchestration platforms, DevOps and CI/CD tools, databases, repositories, etc.** To connect to these third-party services and enable communication between various app components, your software environment needs a way to authenticate the service or app component; this usually happens in the form of a “secret,” i.e., a key, password, certificate, or token.
### How do secrets differ from sensitive data? 
Unlike sensitive data (e.g. social security numbers and credit card info), which typically belong to end users, secrets belong to enterprises. Examples of secrets include:
- LDAP passwords    
- PKI/TLS certificates    
- Encryption key    
- Container credentials    
- SSH keys    
- API tokens  
Developers use secrets to authenticate and establish communication between their systems and other cloud services, or to control human and machine access to sensitive systems.
### Why is secret scanning important?
As digital authentication credentials, secrets—if exposed—can grant adversaries unauthorized access to a company’s code bases, databases, and other sensitive digital infrastructure. 
Unfortunately, securing secrets is not an easy task. While secrets must be encrypted and tightly controlled, they must also be made accessible to engineering teams, apps, and across an entire environment. 

Consequently, at one point or another during the<font color="#ffc000"> software development lifecycle</font> (SDLC), secrets often find their way into potentially exposed spaces: hard-coded credentials in<font color="#ffc000"> continuous integration and continuous delivery </font>(CI/CD) pipelines, code repositories, <font color="#ffc000">version control systems</font> (VCS), security software, containerization environments, or workplace communication channels (e.g., Slack, Teams). 

This happens because devs are focused on writing and shipping quality code at breakneck speed. So when software is still in the development and testing stages, they may consider it ideal to store secrets in local machines to speed up development and facilitate faster feedback loops. 

Enter secret scanning. Let’s discuss the four primary reasons developers should implement it.

### Safeguarding sensitive data and secrets 
To safeguard sensitive data, encrypt it, in transit and at rest, and store it in databases. Secrets are then used to gate-keep the databases, limiting access to authorized humans and machines only. 

**For example, to confirm username/password pairs entered by end users, your login portal must establish an automatic connection to your database.** This connection is authenticated with a secret, authorizing the portal’s access to the sensitive information in the database. If this secret gets leaked along the way or ends up in an unsecured space, unauthorized individuals can access, steal, expose, or encrypt the data for ransomware attacks.

The Microsoft 2023 data exposure incident discovered by the Wiz research team is a perfect demonstration of the significance of secret scanning. In an attempt to publish AI-based training data on GitHub, a Microsoft research team accidentally shared a link that exposed 38 TB of private data, including private keys, secrets, passwords, and over 30,000 internal Microsoft Teams messages, stored in a Microsoft Azure storage account. 

This incident could have been prevented if the team had scanned the account for secrets before releasing the link to GitHub.
### Thwarting cyberattacks 
The [Wiz research team](https://www.wiz.io/blog/secret-based-cloud-supply-chain-attacks-case-study-and-lessons-for-security-teams#1-overprivileged-access-to-container-registries-14) also found forgotten secrets in multiple overlooked locations in CI/CD pipelines, especially container image base layers and Linux bash history files. Attackers can leverage such exposed secrets to conduct cyberattacks using various scenarios. The forgotten secrets can facilitate lateral movement and remote code execution in software supply chain attacks, empowering hackers to modify an enterprise’s source codes, plant malicious code in production-ready artifacts, or tamper with images’ build processes. 

By finding forgotten or hard-coded secrets before they are exposed, secret scanning tools help nip various forms of cyberattackers in the bud.

> Pro tip 
> Agentless scanning solutions typically have quicker setup and deployment and require less maintenance. They can scan all workloads using cloud native APIs and connects to customer environments with a single org-level connector. If the approach is agent-based, this type of deployment will require ongoing agent installation, update, and maintenance effort.

### Improving compliance
Many companies are subject to regulatory standards designed to protect end users’ sensitive personal, financial, and health-related information.  As secrets guard this data, any accidental release of secrets may result in a data breach that could result in hefty noncompliance fines. 

Secret scanning can help detect and prevent secrets from being compromised.

### Protecting against reputational damage and financial loss
Breaches and cyberattacks cause significant reputational damage, negatively impacting revenue and  increasing l costs such as fines, legal fees, and settlements.
### How does secret scanning work?
Secret scanning entails a few steps, performed with specialized tools and methods. Here’s how it works. 

##### Step 1: Scanning
Once a secret scanner is installed and connected to all relevant parts of your IT stack, it conducts real-time or at-rest scans of your stack. 

Real-time scans are event-driven, triggered by pull requests in your version control system (VCS) or code changes in any of the following components of your stack:
- **Code:** Code repositories, config files     
- **Containers:** Container images and Kubernetes architecture    
- **DevOps technology stack:** Build systems, ticketing systems, communication channels, knowledge management systems, bug tracking software, support stack, etc.    
- **Observability pipelines:** Observability/logging software, and data stores    

At-rest scans conduct historical scans of the same components at scheduled intervals. 
##### Secret scanning techniques
As secrets are often embedded in code, logs, etc., identifying them can be tricky. The table below details four secret scanning techniques.

|Scanning technique|Description|Pros|Cons|
|---|---|---|---|
|Regular expression (Regex)|Scans for secrets by specifying a sequence of characters distinctively associated with a service type; e.g., a regex search of a Stripe API key with 200 characters may look like this: SK[a-z0–9]{200}|Reduces false positives since the scanner checks for regular patterns|Secrets with random patterns go undetected due to use of regular expressions. In addition, regular expression scans are computationally expensive and can be slow.|
|Entropy|Analyzes target files for unpredictable strings such as highly random or high entropy strings, e.g., JapFXI/X7MBE/bPEXAMPLEKEY, or not-so-random or low entropy strings, e.g. kkkkkk; results ranked, with high entropy strings believed to be most indicative of a potential secret|Great for detecting highly randomized, unknown, or unpatterned secrets|False positives are common, with scan results listing database IDs, file paths, URLs, etc., which contain random alphanumeric characters as high entropy secrets|
|Dictionary|Finds secrets in target files by comparing character strings in the files to known secrets entered into a secret management tool such as HashiCorp Vault|Known expression patterns used, making secrets easier to verify|Unknown credentials omitted due to use of known expressions. In addition, dictionaries tend to be language specific.|
|Hybrid|Combines two or more scanning techniques; may also involve deploying machine learning technologies|Delivers fewer false positives and detects many more secrets and secret types|Not offered by most secret scanners|
##### Step 2: Identifying and verifying secrets
If the scanner detects a potential secret, it either corresponds with the service provider or extracts metadata within your stack to identify the service that the secret pattern matches; it then detects if it is still valid. 

##### Step 3: Reporting and alerting
If a match is confirmed, the scanner notifies you of the exposed secret. Depending on how comprehensive the tooling is, it may also provide recommendations for resolving the issue. **Note:** Make sure only authorized parties have access to this report, as it would contain sensitive data.

#### Open-source secret scanning tools
##### Detect-secrets
Detect-secrets is a Microsoft project that scans your project’s Git history using heuristics and regex.

|Pros|Cons|
|---|---|
|Fast scans of projects’ current states only, reducing false positives from past secret leaks|Does not identify high-entropy secrets|
|Allows devs to compare heuristic and current commits to prevent repeated secret leaks|Does not run in-depth scans|
##### Gitleaks
Gitleaks scans repos, directories, files, and entire Git histories to detect past and present exposed secrets. It can be installed using Docker, Go, or Homebrew.

|Pros|Cons|
|---|---|
|Compatible with Linux, Windows, and other platforms/OSes|Limited scalability, designed to run on one server only|
|Can be set up to scan code pre-commits to proactively prevent secret exposure|Has no user interface; good for detection only, not incident management|
##### Whispers
Whispers scans static structured text files such as configs, XML, JSON, and Python3 for hard-coded secrets. Unlike the others, it doesn't scan code but instead parses known data formats and extracts key-value pairs to detect secrets. 

|Pros|Cons|
|---|---|
|Allows for custom configuration options, enabling you to remove unwanted results and minimize false positives|Does not scan code or Git repos, only the config files uploaded to Git repos|
|Can detect secrets in pre-commits|Designed as a secondary tool|
##### Git-secrets
Git-secrets is an AWS command-line tool for scanning commits, commit messages, and “–no-ff” merges. 

|Column A|Column B|
|---|---|
|Offers push protection via  a “secret providers” feature that outputs prohibited regex patterns|Limited coverage; ideal for AWS resources only|
|Actively stops commits and merges containing secrets from finding their way into Git repos|Uses regex patterns only; high false-positives|
##### Git-all-secrets 
Git-all-secrets is an aggregation of multiple secret scanners, including TruffleHog (a regular expression-based scanner) and repo-supervisor (a high entropy-based scanner). 

|Pros|Cons|
|---|---|
|Flexible; allows you to specify if a combination of scanners and techniques should be used or not|Only detects secrets in commits; can’t stop secrets from getting into repos|
|Helps lower false positives via multiple techniques|Has a limited user interface and is no longer actively maintained|
##### What about proprietary tools?
Secret scanning can also be done using proprietary tools. Open-source tools come at little to no financial costs, but they also may not offer as much coverage as proprietary tools. Conversely, proprietary tools require varying degrees of financial commitment but typically have more features and offerings. 

Whichever you choose to go with, be sure to look out for the scanning technique the tool uses; for example, a hybrid scanner will help reduce false positives and detect more secret types. Additionally, consider the provider’s reputation and the tool’s ability to conduct real-time monitoring/alerting, incident response, and risk prioritization.
### 6 best practices for secrets management 
On top of scanning secrets, it’s also important to implement the following best practices to properly manage them.  

##### 1. Store and encrypt secrets using a secrets manager
Avoid storing secrets in container images, config files, code, and other unprotected places to prevent secret sprawl. Instead, use dedicated secret management tools (e.g. HashiCorp Vault or AWS Secrets Manager) that encrypt secrets at rest and in transit. 
##### 2. Adopt (regular) secrets rotation and dynamic secrets
Secrets rotation involves periodically changing secrets at preconfigured intervals or manually triggering a change. Using dynamic secrets is one way to implement secret rotation; as opposed to static secrets, these are short-lived, meaning they expire after a specific timeframe or after certain conditions are met. 
Regularly rotating secrets limits a hacker’s window of opportunity, reducing the possibility of compromised secrets being used to conduct cyberattacks. 
##### 3. Restrict access to secrets
Create secret access policies that are consistent across your stack and automate their enforcement. This includes enforcing the <font color="#ffc000">principle of least privilege</font> (PoLP),<font color="#ffc000"> access control lists</font> (ACLs), and <font color="#ffc000">role-based access control</font> (RBAC); these will limit users’ and apps’ access to secrets, data, and infrastructure to a need-to-use basis only. 
If a credential is accidentally compromised, PoLP, ACLs, and RBAC can help shrink the attack surface, limiting a threat actor’s ability to move laterally in your environment.
##### 4. Use placeholders
Avoid hardcoding secrets, as you may need to share code in public repos. The Microsoft incident discussed above is an example of this. Instead of hardcoded secrets, use environment variables to reference secrets in your code. 
##### 5. Track secrets lifecycle
Keep track of secrets currently in use, revoke compromised secrets, and record access events (who’s accessing what and when) in a comprehensive audit log.
##### 6. Implement threat path analysis
Choose a secret scanning tool with advanced attack path analysis; this will detect secrets, correlate them with relevant systems, and give you a clear map of resources and systems on the attack path.

