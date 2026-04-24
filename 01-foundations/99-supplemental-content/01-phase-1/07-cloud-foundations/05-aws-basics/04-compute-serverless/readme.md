# AWS Compute (EC2 & Lambda)

Comparing Virtual Machines (EC2) and Serverless Functions (Lambda).

## Compute Architecture
```mermaid
graph TD
    User request

subgraph Serverless [Lambda]
        Func[Function Code]
        Trigger[API Gateway]
        Trigger --> Func
    end

subgraph Server [EC2]
        VM[Virtual Machine]
        OS[OS Layer]
        App[Application]
        VM --> OS --> App
    end

classDef comp fill:#e3f2fd,stroke:#0d47a1
    class Serverless,Server comp
```

## Real World Scenarios
### Scenario: Image Resizing
**Context:** Users upload profile pictures. You need to create thumbnails.
**Solution:**
- **Lambda:** Trigger function on S3 upload. Resize image. Save to S3.
**Benefit:** You don't pay for a server to sit idle 99% of the time waiting for an upload.

<b>1. EC2 stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Elastic Compute Cloud</b>
</details>


<b>2. Lambda pricing is based on:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Number of requests and Duration (GB-seconds)</b>
</details>


<b>3. Which EC2 purchasing option offers up to 90% discount but can be interrupted?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Spot Instances</b>
</details>


<b>4. Lambda maximum execution time is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) 15 minutes</b>
</details>


<b>5. To scale EC2 automatically, use:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Auto Scaling Group (ASG)</b>
</details>


<b>6. Which EC2 instance family is best for Machine Learning (GPU)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) P or G family</b>
</details>


<b>7. "User Data" in EC2 is used for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Bootstrapping scripts (run once on launch)</b>
</details>


<b>8. Is Lambda stateless?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes (Local disk /tmp is ephemeral)</b>
</details>


<b>9. To expose a Lambda function via HTTP, use:</b>
<details>
<summary>Show Answer</summary>
Answer: A) API Gateway or Function URL</b>
</details>


<b>10. Which EC2 purchasing option requires a 1 or 3 year commitment?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Reserved Instances (RI) / Savings Plans</b>
</details>


<b>11. T-series instances are special because they:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Uses CPU Credits (Burstable performance)</b>
</details>


<b>12. Lambda layers utilize:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Shared code/libraries across functions</b>
</details>


<b>13. AMI stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Amazon Machine Image</b>
</details>


<b>14. Can you attach an IAM Role to an existing EC2 instance?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes (This was a change years ago, now fully supported)</b>
</details>


<b>15. Which Lambda feature keeps a function initialized to prevent cold starts?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Provisioned Concurrency</b>
</details>


<b>16. EC2 Placement Groups determine:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Physical placement of instances (Clustered vs Spread)</b>
</details>


<b>17. Lambda supports which languages?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Node.js, Python, Java, Go, Ruby, .NET, and Custom Runtime (Any)</b>
</details>


<b>18. EC2 Hibernate allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Save RAM state to disk for faster boot</b>
</details>


<b>19. AWS Lightsail is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Simplified VPS provider (good for beginners/simple apps)</b>
</details>


<b>20. Savings Plans are generally more flexible than Reserved Instances. (True/False)</b>
<details>
<summary>Show Answer</summary>
Answer: A) True</b>
</details>


<b>21. Is it possible to mount EFS to Lambda?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>
