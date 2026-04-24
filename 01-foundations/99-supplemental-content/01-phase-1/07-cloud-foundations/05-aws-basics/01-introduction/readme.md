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
**Context:** You manually login to the console every night to download billing CSV's.
**Solution:**
- **AWS CLI:** Write a simple bash script using `aws ce get-cost-and-usage`.
- **Cron Job:** Schedule it to run at 2 AM.
**Benefit:** Saves time and eliminates human error.

<b>1. What is an AWS Region?</b>
<details>
<summary>Show Answer</summary>
Answer: B) A physical location around the world where AWS clusters data centers</b>
</details>


<b>2. How many Availability Zones are normally in a Region?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Minimum 2 (with exceptions), usually 3+</b>
</details>


<b>3. Which command configures your AWS CLI credentials?</b>
<details>
<summary>Show Answer</summary>
Answer: B) aws configure</b>
</details>


<b>4. Credentials for the CLI consist of:</b>
<details>
<summary>Show Answer</summary>
Answer: B) Access Key ID and Secret Access Key</b>
</details>


<b>5. Which output format is default for AWS CLI?</b>
<details>
<summary>Show Answer</summary>
Answer: B) JSON</b>
</details>


<b>6. Can you use the CLI to delete production databases?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Yes, if permissions allow (Dangerous!)</b>
</details>


<b>7. What is "Edge Location"?</b>
<details>
<summary>Show Answer</summary>
Answer: B) A site that CloudFront uses to cache copies of content closer to users</b>
</details>


<b>8. AWS CLI is built on which language SDK?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Python (Boto3)</b>
</details>


<b>9. Which file stores your credentials locally?</b>
<details>
<summary>Show Answer</summary>
Answer: A) ~/.aws/credentials</b>
</details>


<b>10. To list S3 buckets via CLI:</b>
<details>
<summary>Show Answer</summary>
Answer: A) aws s3 ls</b>
</details>


<b>11. What is ARN?</b>
<details>
<summary>Show Answer</summary>
Answer: A) AWS Resource Name (Unique Identifier)</b>
</details>


<b>12. Global Infrastructure includes:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Regions, AZs, Edge Locations</b>
</details>


<b>13. Which command updates the CLI to the latest version?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Depends on OS (e.g., pip install --upgrade awscli)</b>
</details>


<b>14. "Dry Run" flag allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Execute a command without actually making changes (simulate permission check)</b>
</details>


<b>15. Why use Profiles in CLI?</b>
<details>
<summary>Show Answer</summary>
Answer: A) To manage multiple AWS accounts (e.g., --profile prod)</b>
</details>


<b>16. How do you get help for a specific command?</b>
<details>
<summary>Show Answer</summary>
Answer: D) All of the above</b>
</details>


<b>17. Can you run CLI in a Docker container?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


<b>18. Pagination in CLI outputs:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Automatically handles large lists by showing a "NextToken"</b>
</details>


<b>19. Query parameter (`--query`) allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Filter the client-side output using JSONPath</b>
</details>


<b>20. Which partition is standard for most users?</b>
<details>
<summary>Show Answer</summary>
Answer: A) aws</b>
</details>


<b>21. Does CLI support Auto-Completion?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, if configured in shell (e.g., .bashrc)</b>
</details>
