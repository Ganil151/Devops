# 05: Interview Questions and Quizzes

Test your knowledge of Intermediate Prompt Engineering for DevOps.

## 🎤 Top 20 Interview Questions

1.  **What is the 'Chain-of-Thought' technique, and why is it useful for SREs?**
2.  **How do you reduce 'Hallucinations' when generating cloud infrastructure code?**
3.  **What is the difference between Zero-Shot and Few-Shot prompting?**
4.  **How can Role-Based prompting be used for security hardening?**
5.  **What 'Temperature' would you set for generating a bash script? Why?**
6.  **Explain how you would use an LLM to automate a Post-Mortem document.**
7.  **What are the risks of using AI-generated CLI commands in a production terminal?**
8.  **How do you handle 'Context Window' limits when providing long logs to an AI?**
9.  **Explain the 'System Prompt' and how it differs from a 'User Prompt'.**
10. **How can you use Prompt Engineering to improve 'Unit Test' coverage for a legacy app?**
11. **What is 'Reasoning Trace' and how does it help in debugging?**
12. **In a CI/CD pipeline, how could you use AI to review Pull Requests?**
13. **What is 'Throttling' in the context of LLM APIs?**
14. **How do you prompt an AI to only output valid JSON (no natural language commentary)?**
15. **What is 'Top-P' and how does it impact code generation?**
16. **How would you prompt an AI to rewrite a Jenkinsfile to follow 'Dry' principles?**
17. **What is 'Prompt Injection'? Is it a risk in DevOps automation?**
18. **How can you use Few-Shot prompting to maintain a consistent naming convention in Terraform?**
19. **What is the purpose of 'Stop Sequences' in automated prompt chains?**
20. **How do you evaluate if a prompt is 'Good' or 'Bad' for a specific DevOps task?**

---

## 📝 20-Question Knowledge Quiz

1. **Which temperature setting is best for generating a complex Kubernetes YAML file?**
   - A) 1.0
   - B) 0.8
   - C) 0.1
   - D) 0.5

2. **Wait, I just got a 'Hallucination' where the AI suggested a non-existent `kubectl` flag. How do I fix this?**
   - A) Increase Temperature
   - B) Add a constraint: "Only use flags found in the official v1.30 documentation"
   - C) Use shorter prompts
   - D) Reboot the AI

3. **Few-Shot prompting involves:**
   - A) Giving the AI many different tasks at once
   - B) Providing a few examples of input/output pairs
   - C) Asking the AI to try 3 different solutions
   - D) Limiting the AI to 10 tokens

4. **Which technique is best for diagnosing a 'Connection Timeout' between two VPCs?**
   - A) Creative Writing
   - B) Chain-of-Thought
   - C) Zero-Shot
   - D) Random Guessing

5. **In Role-Based prompting, asking the AI to "Act as a Senior Security Engineer" helps it focus on:**
   - A) Writing faster code
   - B) Identifying vulnerabilities and compliance gaps
   - C) Improving the UI design
   - D) Reducing the cloud bill

6. **The 'System Prompt' is used to:**
   - A) Override the User Prompt every time
   - B) Set the high-level behavioral constraints of the AI
   - C) Restart the LLM server
   - D) Clear the history

7. **A 'Context Window' refers to:**
   - A) The size of the browser window
   - B) The total amount of text (input + output) the model can process at once
   - C) The time it takes for a model to respond
   - D) The number of users on the platform

8. **Which model parameter controls the cumulative probability of next-token selection?**
   - A) Temperature
   - B) Max Tokens
   - C) Top-P
   - D) Frequency Penalty

9. **If you want the AI to generate a Runbook from Slack logs, you should:**
   - A) Send the logs as an attachment
   - B) Provide the logs as context and specify a structured format (Markdown)
   - C) Ask the AI to guess what happened
   - D) Just give the AI the ticket number

10. **A reasoning model (like o1) is distinguished by its ability to:**
    - A) Generate images
    - B) Spend more time 'thinking' before providing a response
    - C) Browse the live web
    - D) Speak in multiple languages

11. **True/False: For code-related tasks, a higher temperature increases accuracy.**
    - Answer: **False**.

12. **Which of these is a valid 'Constraint' in a prompt?**
    - A) "Write it quickly"
    - B) "Do not use deprecated AWS resources"
    - C) "Make it look nice"
    - D) "Explain it like I'm 5"

13. **Providing 'Feedback' to an AI's output in a multi-turn conversation is known as:**
    - A) Active Learning
    - B) Chain-of-Thought
    - C) Prompt Chaining / Refinement
    - D) RAG

14. **Why would a DevOps engineer use a 'Coding-Specialized' model?**
    - A) Because it's better at writing poetry
    - B) Because it has been fine-tuned on vast amounts of open-source scripts and manifests
    - C) Because it's cheaper
    - D) Because it has a larger context window

15. **What is 'Prompt Chaining'?**
    - A) Connecting multiple AI models together
    - B) Carrying out a task by passing the output of one prompt as the input to the next
    - C) Using the same prompt for 10 different tasks
    - D) Using a very long prompt

16. **To ensure a valid JSON output, a good tip is to:**
    - A) Ask the AI to be careful
    - B) Provide a JSON schema and specify: "Return ONLY the JSON object"
    - C) Use temperature 1.0
    - D) Ask for XML instead

17. **Which 'Setting' affects the maximum length of a generated script?**
   - A) Temperature
   - B) Top-P
   - C) Max Tokens
   - D) Presence Penalty

18. **Role-based prompting: "Act as an SRE" will likely result in a focus on:**
    - A) Aesthetics and colors
    - B) Reliability, latency, and scalability
    - C) Marketing copy
    - D) Database schema design for games

19. **What is a 'Hallucination' in LLMs?**
    - A) When the AI crashes
    - B) When the AI confidently provides incorrect or fabricated information
    - C) When the AI refuses to answer
    - D) When the AI repeats itself

20. **Combining business metrics with technical logs in a prompt helps with:**
    - A) FinOps and Unit Economics analysis
    - B) Speeding up the response
    - C) Reducing token usage
    - D) Nothing

<details>
<summary><b>View Answers</b></summary>
1: C, 2: B, 3: B, 4: B, 5: B, 6: B, 7: B, 8: C, 9: B, 10: B, 11: False, 12: B, 13: C, 14: B, 15: B, 16: B, 17: C, 18: B, 19: B, 20: A
</details>
