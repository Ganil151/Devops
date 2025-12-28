# AWS Introduction & CLI

A standardized starting point for AWS. This module consolidates core concepts and CLI setup.

## Overview
- **Fundamentals:** Understanding Regions, Availability Zones, and the Global Infrastructure.
- **CLI:** Automating AWS interactions from your terminal.

## Core Concepts
```mermaid
graph TD
    Region[AWS Region]
    AZ1[Availability Zone 1]
    AZ2[Availability Zone 2]
    DC1[Data Center A]
    DC2[Data Center B]
    
    Region --> AZ1
    Region --> AZ2
    AZ1 --> DC1
    AZ2 --> DC2
    
    classDef region fill:#e3f2fd,stroke:#0d47a1
    classDef az fill:#fff3e0,stroke:#e65100
    
    class Region region
    class AZ1,AZ2 az
```

## Real World Scenarios
### Scenario: Automated Nightly Reports
**Context:** You manually login to the console every night to download billing CSVs.
**Solution:**
- **AWS CLI:** Write a simple bash script using `aws ce get-cost-and-usage`.
- **Cron Job:** Schedule it to run at 2 AM.
**Benefit:** Saves time and eliminates human error.

## Quiz
<details>
<summary><b>1. What is an AWS Region?</b></summary>
A) A single data center<br>
B) A physical location around the world where AWS clusters data centers<br>
C) A rack of servers<br>
D) A country<br>
<br>
<b>Answer: B) A physical location around the world where AWS clusters data centers</b>
</details>

<details>
<summary><b>2. How many Availability Zones are normally in a Region?</b></summary>
A) Always 1<br>
B) Minimum 2 (with exceptions), usually 3+<br>
C) 100<br>
D) 0<br>
<br>
<b>Answer: B) Minimum 2 (with exceptions), usually 3+</b>
</details>

<details>
<summary><b>3. Which command configures your AWS CLI credentials?</b></summary>
A) aws login<br>
B) aws configure<br>
C) aws init<br>
D) aws setup<br>
<br>
<b>Answer: B) aws configure</b>
</details>

<details>
<summary><b>4. Credentials for the CLI consist of:</b></summary>
A) Username and Password<br>
B) Access Key ID and Secret Access Key<br>
C) Email and PIN<br>
D) Fingerprint<br>
<br>
<b>Answer: B) Access Key ID and Secret Access Key</b>
</details>

<details>
<summary><b>5. Which output format is default for AWS CLI?</b></summary>
A) Table<br>
B) JSON<br>
C) Text<br>
D) YAML<br>
<br>
<b>Answer: B) JSON</b>
</details>

<details>
<summary><b>6. Can you use the CLI to delete production databases?</b></summary>
A) No, only Console can do that<br>
B) Yes, if permissions allow (Dangerous!)<br>
<br>
<b>Answer: B) Yes, if permissions allow (Dangerous!)</b>
</details>

<details>
<summary><b>7. What is "Edge Location"?</b></summary>
A) A CLI tool<br>
B) A site that CloudFront uses to cache copies of content closer to users<br>
C) A backup server<br>
D) A deprecated feature<br>
<br>
<b>Answer: B) A site that CloudFront uses to cache copies of content closer to users</b>
</details>

<details>
<summary><b>8. AWS CLI is built on which language SDK?</b></summary>
A) Java<br>
B) Python (Boto3)<br>
C) C++<br>
D) Ruby<br>
<br>
<b>Answer: B) Python (Boto3)</b>
</details>

<details>
<summary><b>9. Which file stores your credentials locally?</b></summary>
A) ~/.aws/credentials<br>
B) ~/.ssh/id_rsa<br>
C) Documents/passwords.txt<br>
D) Windows Registry<br>
<br>
<b>Answer: A) ~/.aws/credentials</b>
</details>

<details>
<summary><b>10. To list S3 buckets via CLI:</b></summary>
A) aws s3 ls<br>
B) aws s3 list-buckets<br>
C) aws s3 show<br>
D) aws list s3<br>
<br>
<b>Answer: A) aws s3 ls</b>
</details>

<details>
<summary><b>11. What is ARN?</b></summary>
A) AWS Resource Name (Unique Identifier)<br>
B) A random number<br>
C) Access Role Network<br>
D) Amazon Route Network<br>
<br>
<b>Answer: A) AWS Resource Name (Unique Identifier)</b>
</details>

<details>
<summary><b>12. Global Infrastructure includes:</b></summary>
A) Regions, AZs, Edge Locations<br>
B) Only US-East-1<br>
C) Office buildings<br>
D) Employees<br>
<br>
<b>Answer: A) Regions, AZs, Edge Locations</b>
</details>

<details>
<summary><b>13. Which command updates the CLI to the latest version?</b></summary>
A) aws update<br>
B) Depends on OS (e.g., pip install --upgrade awscli)<br>
C) aws self-update<br>
D) It updates automatically<br>
<br>
<b>Answer: B) Depends on OS (e.g., pip install --upgrade awscli)</b>
</details>

<details>
<summary><b>14. "Dry Run" flag allows you to:</b></summary>
A) Execute a command without actually making changes (simulate permission check)<br>
B) Run faster<br>
C) Run slowly<br>
D) Delete everything<br>
<br>
<b>Answer: A) Execute a command without actually making changes (simulate permission check)</b>
</details>

<details>
<summary><b>15. Why use Profiles in CLI?</b></summary>
A) To manage multiple AWS accounts (e.g., --profile prod)<br>
B) To look cool<br>
C) It's mandatory<br>
D) It saves disk space<br>
<br>
<b>Answer: A) To manage multiple AWS accounts (e.g., --profile prod)</b>
</details>

<details>
<summary><b>16. How do you get help for a specific command?</b></summary>
A) aws help<br>
B) aws ec2 help<br>
C) aws s3 cp help<br>
D) All of the above<br>
<br>
<b>Answer: D) All of the above</b>
</details>

<details>
<summary><b>17. Can you run CLI in a Docker container?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>

<details>
<summary><b>18. Pagination in CLI outputs:</b></summary>
A) Automatically handles large lists by showing a "NextToken"<br>
B) Is not supported<br>
C) Crashes the terminal<br>
D) Only prints first 10 items<br>
<br>
<b>Answer: A) Automatically handles large lists by showing a "NextToken"</b>
</details>

<details>
<summary><b>19. Query parameter (`--query`) allows you to:</b></summary>
A) Filter the client-side output using JSONPath<br>
B) Change the API call<br>
C) Hack AWS<br>
D) Increase speed<br>
<br>
<b>Answer: A) Filter the client-side output using JSONPath</b>
</details>

<details>
<summary><b>20. Which partition is standard for most users?</b></summary>
A) aws<br>
B) aws-cn (China)<br>
C) aws-us-gov (GovCloud)<br>
D) invalid<br>
<br>
<b>Answer: A) aws</b>
</details>

<details>
<summary><b>21. Does CLI support Auto-Completion?</b></summary>
A) Yes, if configured in shell (e.g., .bashrc)<br>
B) No<br>
<br>
<b>Answer: A) Yes, if configured in shell (e.g., .bashrc)</b>
</details>
