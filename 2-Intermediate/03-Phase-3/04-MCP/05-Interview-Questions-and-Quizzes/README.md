# 05: Interview Questions and Quizzes

Test your knowledge of the Model Context Protocol (MCP) and its role in Agentic AI.

## 🎤 Top 20 Interview Questions

1.  **What is the Model Context Protocol (MCP), and what problem does it solve?**
2.  **Explain the difference between an MCP 'Host', 'Client', and 'Server'.**
3.  **How does MCP differ from traditional REST APIs for AI integration?**
4.  **What are 'Tools' in the context of an MCP server?**
5.  **What is a 'Resource' in MCP, and how is it used by an LLM?**
6.  **Explain the security risks of giving an AI model high-privilege MCP tools.**
7.  **How would you build an MCP server that interacts with a database?**
8.  **What is 'Human-in-the-loop', and why is it critical for MCP?**
9.  **Which SDKs are currently available for building MCP servers?**
10. **How does an MCP client discover what tools a server offers?**
11. **Explain the difference between 'Stdio' and 'SSE' transports in MCP.**
12. **How can MCP be used to improve Kubernetes troubleshooting?**
13. **What is 'Context Injection', and how does MCP automate it?**
14. **Can one MCP host connect to multiple MCP servers simultaneously?**
15. **How do you handle 'Structured Output' (like JSON) in an MCP response?**
16. **Why is 'Least Privilege' important for the credentials used by an MCP server?**
17. **What is a 'Prompt' in the MCP specification?**
18. **How would you debug a connection failure between a Host and an MCP server?**
19. **What is the role of the 'Host' in approving tool calls?**
20. **How does MCP impact the future of DevOps 'Sidekick' assistants?**

---

## 📝 20-Question Knowledge Quiz

1. **Who developed the Model Context Protocol?**
   - A) OpenAI
   - B) Google
   - C) Anthropic
   - D) Microsoft

2. **The MCP 'Server' primary job is to:**
   - A) Run the Large Language Model
   - B) Expose tools and resources to the AI host
   - C) Store the user's chat history
   - D) Manage the GPU cluster

3. **Which transport is typically used for local MCP servers (e.g., on your laptop)?**
   - A) gRPC
   - B) Stdio (Standard Input/Output)
   - C) Webhooks
   - D) FTP

4. **In the MCP architecture, the 'Host' is usually:**
   - A) The database
   - B) The AI application (like Claude Desktop or an IDE)
   - C) The cloud provider
   - D) The human user

5. **A 'Tool' in MCP requires a \_\_\_\_\_\_ to define its arguments.**
   - A) CSV file
   - B) JSON Schema
   - C) Python Class
   - D) Markdown Table

<b>6. </b>
<details>
<summary>Show Answer</summary>
Answer: **False**.
</details>


7. **What happens during the 'Discovery' phase?**
   - A) The user searches for AI models
   - B) The Host queries the Server for a list of available tools/resources
   - C) The Server downloads the latest AI model
   - D) The network is scanned for vulnerabilities

8. **Which of these is a valid 'Resource' URI?**
   - A) `https://google.com`
   - B) `file:///etc/hosts`
   - C) `mcp://local/logs`
   - D) `postgres://db:5432`

9. **'SSE' steht für:**
    - A) Standard Service Entry
    - B) Server-Sent Events
    - C) Secure Socket Encryption
    - D) Simple Serial Exchange

10. **Why is 'Max Tokens' relevant for an MCP server?**
    - A) To limit the AI's imagination
    - B) To ensure the tool's response doesn't exceed the model's context window
    - C) To speed up the internet
    - D) It isn't relevant

11. **The 'Human-in-the-loop' pattern is primarily for:**
    - A) Performance
    - B) Safety and Security
    - C) Compliance
    - D) Cost reduction

12. **Which SDK would you use if you are a Python developer?**
    - A) MCP-js
    - B) MCP-python
    - C) MCP-go
    - D) MCP-rust

13. **Tools in MCP are similar to \_\_\_\_\_\_ in other AI frameworks.**
    - A) Models
    - B) Agents
    - C) Function Calling
    - D) Embeddings

14. **What is 'Sampling' in the MCP specification?**
    - A) Testing a small part of the data
    - B) Allowing a server to request a completion from the host's model
    - C) Picking a random tool
    - D) Monitoring response times

15. **A 'destructive' tool call should always reach the \_\_\_\_\_\_ state.**
    - A) Automatic Execution
    - B) Silent Failure
    - C) User Approval / Confirmation
    - D) Infinite Loop

16. **How do you pass credentials (like API keys) to an MCP server?**
    - A) Hardcode them in the tool code
    - B) Pass them via Environment Variables to the server process
    - C) Send them in the chat message
    - D) Use a public S3 bucket

17. **Which of these is a benefit of containerizing an MCP server?**
    - A) Isolation and portability
    - B) Making it run slower
    - C) Increasing the cost
    - D) Making it easier for hackers

18. **An MCP 'Prompt' is used to:**
    - A) Ask the user for money
    - B) Provide the AI with structured templates for specific tasks
    - C) Restart the computer
    - D) Measure latency

19. **Can an MCP server be written in languages other than Python/JS?**
    - A) No, never
    - B) Yes, by implementing the JSON-RPC spec directly
    - C) Only if the AI permits it
    - D) Only in C++

20. **MCP aims to solve the 'Fragmented Integration' problem by:**
    - A) Building a single AI for everything
    - B) Providing a standard way for any AI to talk to any tool
    - C) Deleting all APIs
    - D) Moving everything to the cloud

<details>
<summary><b>View Answers</b></summary>
1: C, 2: B, 3: B, 4: B, 5: B, 6: False, 7: B, 8: C, 9: B, 10: B, 11: B, 12: B, 13: C, 14: B, 15: C, 16: B, 17: A, 18: B, 19: B, 20: B
</details>