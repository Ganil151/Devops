# 05: Interview Questions and Quizzes

Test your knowledge of API Gateways and Security.

## 🎤 Top 20 Interview Questions

1. **What is the primary role of an API Gateway in a microservices architecture?**
2. **Compare an API Gateway with a Service Mesh. When would you use which?**
3. **What is JWT and why is it preferred over Session Cookies for microservices?**
4. **Explain the three parts of a JWT.**
5. **How does an API Gateway handle 'Aggregation'?**
6. **What is Rate Limiting, and which algorithm allows for bursts of traffic?**
7. **Define 'CORS' and why it matters for API security.**
8. **What is the difference between OAuth2 and OpenID Connect?**
9. **How do you implement 'Circuit Breaker' at the gateway level?**
10. **What is 'SSL Termination' and why is it done at the Gateway?**
11. **Explain the 'Strangler Fig' pattern in the context of API Gateways.**
12. **What are 'Scopes' in OAuth2?**
13. **How does a Gateway handle 'Protocol Translation'?**
14. **What is the difference between Authentication and Authorization?**
15. **What is the purpose of the 'Refresh Token'?**
16. **How do you protect an API against a Replay Attack?**
17. **What is 'Throttling' and how does it differ from Rate Limiting?**
18. **Why is 'Backend-for-Frontend' (BFF) used alongside an API Gateway?**
19. **What is Swagger/OpenAPI, and why is it important for DevOps?**
20. **How do you secure a Gateway itself (The 'Gatekeeper' problem)?**

---

## 📝 20-Question Knowledge Quiz

1. **Which layer of the OSI model does an API Gateway primarily operate at?**
   - A) Layer 3
   - B) Layer 4
   - C) Layer 7
   - D) Layer 2

2. **What is the separator used between the three parts of a JWT?**
   - A) Colon (:)
   - B) Dot (.)
   - C) Hyphen (-)
   - D) Semicolon (;)

3. **Which algorithm is best for ensuring a strict, constant outflow of requests?**
   - A) Token Bucket
   - B) Fixed Window
   - C) Leaky Bucket
   - D) Random Drop

4. **In OAuth2, the 'Client' refers to:**
   - A) The End User
   - B) The Database
   - C) The Application requesting access
   - D) The Developer

5. **A JWT's signature is used to:**
   - A) Encrypt the payload
   - B) Verify the sender and ensure data integrity
   - C) Speed up the request
   - D) Hide user permissions

6. **What status code is typically returned when a client is Rate Limited?**
   - A) 401 Unauthorized
   - B) 403 Forbidden
   - C) 429 Too Many Requests
   - D) 503 Service Unavailable

7. **OAuth2 is primarily a(n) \_\_\_\_\_\_ protocol.**
   - A) Authentication
   - B) Authorization
   - C) Encryption
   - D) Transport

8. **OpenID Connect (OIDC) sits on top of:**
   - A) Basic Auth
   - B) SAML
   - C) OAuth2
   - D) Kerberos

9. **Which component is responsible for distributing traffic to instances of the SAME service?**
   - A) API Gateway
   - B) Load Balancer
   - C) NAT Gateway
   - D) Service Discovery

10. **A 'Circuit Breaker' in 'Open' state will:**
    - A) Allow all traffic
    - B) Block all traffic to the failing service
    - C) Allow 50% of traffic
    - D) Send traffic to a backup database

11. **Swagger UI is used to:**
    - A) Write code
    - B) Deploy containers
    - C) Visualize and test APIs
    - D) Monitor CPU usage

12. **Which header is commonly used to pass a JWT to an API?**
    - A) Content-Type
    - B) Accept
    - C) Authorization
    - D) X-Custom-Token

13. **The 'claims' in a JWT are located in the:**
    - A) Header
    - B) Payload
    - C) Signature
    - D) Metadata

14. **What does 'aggregation' in a gateway help reduce?**
    - A) Security risks
    - B) Client-side round trips
    - C) Disk usage
    - D) Code complexity

15. **A 'Refresh Token' is typically \_\_\_\_\_\_ than an Access Token.**
    - A) Longer-lived
    - B) Shorter-lived
    - C) More encrypted
    - D) Larger in size

16. **Rate limiting based on IP address can be bypassed by users using:**
    - A) A different browser
    - B) VPNs or Proxies
    - C) A faster internet connection
    - D) SSL certificates

17. **Which tool is NOT an API Gateway?**
    - A) Kong
    - B) Tyk
    - C) Jenkins
    - D) AWS API Gateway

18. **The 'Fixed Window' algorithm can suffer from:**
    - A) Memory leaks
    - B) Boundary spikes
    - C) Slow performance
    - D) Large token sizes

19. **What is an 'Idempotent' request?**
    - A) A request that always fails
    - B) A request that can be made multiple times with the same result
    - C) A request that modifies multiple tables
    - D) A request that requires two Factor Auth

20. **Storing sensitive user passwords inside a JWT payload is:**
    - A) Best practice
    - B) Highly insecure
    - C) Mandatory for OAuth2
    - D) Good for performance

<details>
<summary><b>View Answers</b></summary>
1: C, 2: B, 3: C, 4: C, 5: B, 6: C, 7: B, 8: C, 9: B, 10: B, 11: C, 12: C, 13: B, 14: B, 15: A, 16: B, 17: C, 18: B, 19: B, 20: B
</details>
