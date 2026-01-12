# 08: Interview Questions and Quizzes

Mastering Cloud Engineering requires a deep understanding of architecture, availability, and specific cloud services (AWS focused).

## 🎤 Top 20 Interview Questions

1.  **What is the difference between Scalability and Elasticity?**
2.  **Explain the Shared Responsibility Model in AWS.**
3.  **What is a VPC, and what are its core components (Subnets, Route Tables, IGW)?**
4.  **How do you ensure High Availability for a web application on AWS?**
5.  **What is the difference between a Public Subnet and a Private Subnet?**
6.  **How does AWS IAM work? Explain Users, Groups, Roles, and Policies.**
7.  **What is 'Infrastructure as Code' (IaC), and why is it essential for Cloud Engineering?**
8.  **Compare AWS Lambda with AWS EC2. When would you use each?**
9.  **What is the purpose of an Application Load Balancer (ALB) vs. a Network Load Balancer (NLB)?**
10. **How do you handle secrets management in the cloud (e.g., AWS Secrets Manager vs. Parameter Store)?**
11. **Explain S3 Storage Classes and when to use Glacier.**
12. **What is 'Cloud-Native', and how does it differ from traditional virtualization?**
13. **What is the 'Least Privilege' principle in IAM?**
14. **How do you monitor cloud resources and set up alerts (e.g., CloudWatch)?**
15. **What is an 'Auto Scaling Group' (ASG), and how does it determine when to scale?**
16. **Explain 'Blue-Green' vs. 'Canary' deployment strategies in the cloud.**
17. **What is a 'NAT Gateway', and why is it needed for private subnets?**
18. **How do you optimize cloud costs (FinOps)?**
19. **What is 'Serverless', and what are its pros and cons?**
20. **Explain the difference between EBS, EFS, and S3.**

---

## 📝 20-Question Knowledge Quiz

1.  **Which AWS service is used for scalable, object-based storage?**
    - A) EC2
    - B) EBS
    - C) S3
    - D) RDS

2.  **What provides a secure 'tunnel' for connecting an on-premises data center to AWS?**
    - A) Internet Gateway
    - B) Direct Connect / Site-to-Site VPN
    - C) NAT Gateway
    - D) VPC Peering

3.  **A 'Role' in IAM is primarily used for:**
    - A) Giving a specific user a password
    - B) Granting temporary permissions to services or users
    - C) Organizing users into departments
    - D) Setting up billing alerts

4.  **Which load balancer operates at Layer 4 (Transport Layer)?**
    - A) Application Load Balancer
    - B) Network Load Balancer
    - C) Classic Load Balancer
    - D) Gateway Load Balancer

5.  **What is the primary benefit of Multi-AZ deployments?**
    - A) Lower cost
    - B) High Availability and Fault Tolerance
    - C) Faster deployments
    - D) Simplified networking

6.  **Which service allows you to run code without provisioning or managing servers?**
    - A) AWS EC2
    - B) AWS Lambda
    - C) AWS Fargate
    - D) Both B and C

7.  **A CIDR block of `10.0.0.0/16` contains how many IP addresses?**
    - A) 256
    - B) 1,024
    - C) 65,536
    - D) 4,096

8.  **AWS CloudTrail is primarily used for:**
    - A) Monitoring CPU usage
    - B) Auditing API calls and user activity
    - C) Storing log files
    - D) Managing DNS records

9.  **Which S3 storage class is best for long-term archive data accessed once a year?**
    - A) S3 Standard
    - B) S3 Intelligent-Tiering
    - C) S3 Glacier Deep Archive
    - D) S3 One Zone-IA

10. **What is the purpose of a 'Route Table' in a VPC?**
    - A) To store DNS records
    - B) To determine where network traffic is directed
    - C) To define firewall rules
    - D) To assign IP addresses to instances

11. **In the Shared Responsibility Model, who is responsible for 'Security OF the Cloud'?**
    - A) The Customer
    - B) AWS
    - C) Both
    - D) Third-party auditors

12. **Which tool is used to provision AWS infrastructure using a declarative template?**
    - A) AWS CLI
    - B) AWS CloudFormation / Terraform
    - C) AWS SDK
    - D) AWS Systems Manager

13. **An 'Instance Profile' is used to:**
    - A) Store user passwords
    - B) Pass an IAM Role to an EC2 instance
    - C) Configure SSH keys
    - D) Set the instance type

14. **Which service provides a managed Relational Database (SQL)?**
    - A) DynamoDB
    - B) ElastiCache
    - C) RDS
    - D) Redshift

15. **What is 'Vertical Scaling'?**
    - A) Adding more instances to a cluster
    - B) Increasing the CPU/RAM of an existing instance
    - C) Moving instances to a different region
    - D) Deleting unused resources

16. **A 'Security Group' acts as a firewall at the \_\_\_\_\_\_ level.**
    - A) Subnet
    - B) Instance/ENI
    - C) VPC
    - D) Account

17. **Which service is a globally distributed Content Delivery Network (CDN)?**
    - A) Route 53
    - B) CloudFront
    - C) Direct Connect
    - D) Global Accelerator

18. **AWS Config is used for:**
    - A) Deploying code
    - B) Monitoring and auditing resource configurations
    - C) Running shell scripts
    - D) Monitoring network latency

19. **What is the main difference between EBS and EFS?**
    - A) EBS is block storage; EFS is file storage
    - B) EBS is for one instance; EFS can be shared by many
    - C) EBS is cheaper; EFS is faster
    - D) Both A and B

20. **Which status code indicates an AWS API request was throttled?**
    - A) 400 Bad Request
    - B) 403 Forbidden
    - C) 429 Too Many Requests / 503 Service Unavailable
    - D) 404 Not Found

<details>
<summary><b>View Answers</b></summary>
1: C, 2: B, 3: B, 4: B, 5: B, 6: D, 7: C, 8: B, 9: C, 10: B, 11: B, 12: B, 13: B, 14: C, 15: B, 16: B, 17: B, 18: B, 19: D, 20: C
</details>