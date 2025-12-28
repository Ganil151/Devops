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

## Quiz
<details>
<summary><b>1. EC2 stands for:</b></summary>
A) Elastic Compute Cloud<br>
B) Easy Computer Cloud<br>
C) Elastic Cloud Computer<br>
D) Enterprise Cloud Core<br>
<br>
<b>Answer: A) Elastic Compute Cloud</b>
</details>

<details>
<summary><b>2. Lambda pricing is based on:</b></summary>
A) Number of requests and Duration (GB-seconds)<br>
B) Hourly rate<br>
C) Storage used<br>
D) CPU speed<br>
<br>
<b>Answer: A) Number of requests and Duration (GB-seconds)</b>
</details>

<details>
<summary><b>3. Which EC2 purchasing option offers up to 90% discount but can be interrupted?</b></summary>
A) Spot Instances<br>
B) On-Demand<br>
C) Reserved Instances<br>
D) Dedicated Hosts<br>
<br>
<b>Answer: A) Spot Instances</b>
</details>

<details>
<summary><b>4. Lambda maximum execution time is:</b></summary>
A) 15 minutes<br>
B) 5 minutes<br>
C) 1 hour<br>
D) Unlimited<br>
<br>
<b>Answer: A) 15 minutes</b>
</details>

<details>
<summary><b>5. To scale EC2 automatically, use:</b></summary>
A) Auto Scaling Group (ASG)<br>
B) Bigger instance<br>
C) More money<br>
D) Lambda<br>
<br>
<b>Answer: A) Auto Scaling Group (ASG)</b>
</details>

<details>
<summary><b>6. Which EC2 instance family is best for Machine Learning (GPU)?</b></summary>
A) P or G family<br>
B) T family<br>
C) R family<br>
D) M family<br>
<br>
<b>Answer: A) P or G family</b>
</details>

<details>
<summary><b>7. "User Data" in EC2 is used for:</b></summary>
A) Bootstrapping scripts (run once on launch)<br>
B) Storing user passwords<br>
C) Metadata<br>
D) Nothing<br>
<br>
<b>Answer: A) Bootstrapping scripts (run once on launch)</b>
</details>

<details>
<summary><b>8. Is Lambda stateless?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes (Local disk /tmp is ephemeral)</b>
</details>

<details>
<summary><b>9. To expose a Lambda function via HTTP, use:</b></summary>
A) API Gateway or Function URL<br>
B) VPC Peering<br>
C) Route53<br>
D) S3<br>
<br>
<b>Answer: A) API Gateway or Function URL</b>
</details>

<details>
<summary><b>10. Which EC2 purchasing option requires a 1 or 3 year commitment?</b></summary>
A) Reserved Instances (RI)<br>
B) Spot<br>
C) On-Demand<br>
D) Dedicated<br>
<br>
<b>Answer: A) Reserved Instances (RI) / Savings Plans</b>
</details>

<details>
<summary><b>11. T-series instances are special because they:</b></summary>
A) Uses CPU Credits (Burstable performance)<br>
B) Are free<br>
C) Have GPUs<br>
D) Are faster<br>
<br>
<b>Answer: A) Uses CPU Credits (Burstable performance)</b>
</details>

<details>
<summary><b>12. Lambda layers utilize:</b></summary>
A) Shared code/libraries across functions<br>
B) Multiple servers<br>
C) Docker<br>
D) OSI model<br>
<br>
<b>Answer: A) Shared code/libraries across functions</b>
</details>

<details>
<summary><b>13. AMI stands for:</b></summary>
A) Amazon Machine Image<br>
B) Amazon Main Interface<br>
C) Azure Machine Image<br>
D) Automated Machine Install<br>
<br>
<b>Answer: A) Amazon Machine Image</b>
</details>

<details>
<summary><b>14. Can you attach an IAM Role to an existing EC2 instance?</b></summary>
A) Yes<br>
B) No, only at launch<br>
<br>
<b>Answer: A) Yes (This was a change years ago, now fully supported)</b>
</details>

<details>
<summary><b>15. Which Lambda feature keeps a function initialized to prevent cold starts?</b></summary>
A) Provisioned Concurrency<br>
B) Warm-up script<br>
C) Keeping computer on<br>
D) Auto Scaling<br>
<br>
<b>Answer: A) Provisioned Concurrency</b>
</details>

<details>
<summary><b>16. EC2 Placement Groups determine:</b></summary>
A) Physical placement of instances (Clustered vs Spread)<br>
B) Which region they are in<br>
C) Which VPC they are in<br>
D) The price<br>
<br>
<b>Answer: A) Physical placement of instances (Clustered vs Spread)</b>
</details>

<details>
<summary><b>17. Lambda supports which languages?</b></summary>
A) Node.js, Python, Java, Go, Ruby, .NET, and Custom Runtime (Any)<br>
B) Only Python<br>
C) Only Java<br>
D) Only C++<br>
<br>
<b>Answer: A) Node.js, Python, Java, Go, Ruby, .NET, and Custom Runtime (Any)</b>
</details>

<details>
<summary><b>18. EC2 Hibernate allows you to:</b></summary>
A) Save RAM state to disk for faster boot<br>
B) Sleep the server<br>
C) Stop billing<br>
D) Delete data<br>
<br>
<b>Answer: A) Save RAM state to disk for faster boot</b>
</details>

<details>
<summary><b>19. AWS Lightsail is:</b></summary>
A) Simplified VPS provider (good for beginners/simple apps)<br>
B) A database<br>
C) A load balancer<br>
D) A container<br>
<br>
<b>Answer: A) Simplified VPS provider (good for beginners/simple apps)</b>
</details>

<details>
<summary><b>20. Savings Plans are generally more flexible than Reserved Instances. (True/False)</b></summary>
A) True<br>
B) False<br>
<br>
<b>Answer: A) True</b>
</details>

<details>
<summary><b>21. Is it possible to mount EFS to Lambda?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>
