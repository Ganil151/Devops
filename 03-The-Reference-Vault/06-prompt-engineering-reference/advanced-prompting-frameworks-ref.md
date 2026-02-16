# Advanced Prompting Strategies Reference

**Doc Version:** 1.0.0
**Role:** Prompt Engineer
**Scope:** Optimization Techniques for Complex Logic

---

## 1. Zero-Shot vs. Few-Shot Prompting

### Zero-Shot
Asking the model to perform a task without examples.
* **Use Case**: Simple tasks like summarization or sentiment analysis on common topics.
* **Prompt**: `Classify this email as spam or not: "Buy cheap meds now!"`

### Few-Shot (In-Context Learning)
Providing "Shot" examples in the context window to guide the model's pattern recognition.
* **Mechanism**: The model attends to the examples to understand the *format* and *tone* required.
* **Impact**: Significantly improves accuracy on complex formats (like generating specific JSON schemas or SQL queries).

**Example:**
```text
Task: Convert Logs to JSON.

Log: [ERROR] DB Connection Failed
JSON: {"level": "ERROR", "msg": "DB Connection Failed"}

Log: [INFO] Service Started
JSON: {"level": "INFO", "msg": "Service Started"}

Log: [WARN] High Latency
JSON: 
```

---

## 2. Chain-of-Thought (CoT)

Forcing the model to "think out loud" before answering.
* **The Problem**: LLMs struggle with multi-step math or logic if forced to give an immediate answer.
* **The Solution**: Append `Let's think step by step.`
* **Result**: The model generates intermediate tokens (reasoning steps), which serve as *context* for the final answer validation.

> **Enterprise Usage**: Critical for **Root Cause Analysis (RCA)** bots. Do not ask for the "Root Cause" immediately. Ask the model to "List observed symptoms, analyze dependencies, and then deduce the root cause."

---

## 3. ReAct (Reason + Act)

A framework where the LLM can use **Tools**.
1.  **Reason**: The model thinks "I need to check the server CPU usage."
2.  **Act**: The model outputs a special token/command: `[TOOL: GET_METRICS(host='db-01')]`.
3.  **Observation**: The system runs the command and feeds the output back to the LLM.
4.  **Reason**: "CPU is 99%. This indicates a loop."

**Visual Flow:**
`Thought -> Action -> Observation -> Thought -> Final Answer`

---

## 4. Prompt Governance Patterns

When deploying prompts to production APIs:

1.  **Delimiters**: Always enclose user input in delimiters (```, """, <input>) to prevent prompt injection.
    *   *Bad*: `Translate this: {user_input}`
    *   *Good*: `Translate the text inside the XML tags: <text>{user_input}</text>`
2.  **Output Parsing**: Instruct the model to output strict formats (e.g., `Respond ONLY in JSON. Do not include markdown blocks.`).

---

## 5. RAG (Retrieval-Augmented Generation)

Connecting LLMs to private data.
*   **Vector DB**: Store documentation chunks as embeddings.
*   **Retrieval**: User query -> Search Vector DB -> Get relevant chunks.
*   **Augmentation**: Inject chunks into the Context Window.
*   **Generation**: LLM answers based on the chunks.

**Ref:** *This turns the "Closed Book" exam into an "Open Book" exam.*
