# 04: LLM Settings for Code and Config

To get reliable results for DevOps tasks, you must understand the "knobs and dials" of Large Language Models.

## 🌡️ The "Temperature" Setting

Temperature controls the randomness of the model's output.

- **Low (0.0 - 0.2)**: "Focused and Predictable." Best for code generation, YAML files, and CLI commands where precision is vital.
- **Medium (0.5 - 0.7)**: "Balanced." Good for blog posts or documentation summaries.
- **High (0.8 - 1.0)**: "Creative." Rarely used in DevOps, as it increases the risk of "hallucinating" non-existent flags or commands.

---

## 📊 Other Key Parameters

### 1. Top-P (Nucleus Sampling)
An alternative to temperature. It restricts the model to the most likely tokens whose cumulative probability exceeds P. For code, keep this low (e.g., 0.1).

### 2. Max Tokens
Limits the length of the response. For generating large Kubernetes manifest files, ensure this is set high enough so the code doesn't get cut off.

### 3. Stop Sequences
Tokens that tell the model to stop generating. Useful for ensuring the AI doesn't start "explaining" after it finishes writing a script.

---

## ⚡ The DevOps "Golden Configuration"

| Task | Temperature | Top-P | Best Model Type |
| :--- | :--- | :--- | :--- |
| **YAML/Terraform** | 0.1 | 0.1 | Coding-specialized (e.g., Claude 3.5, GPT-4o) |
| **Troubleshooting** | 0.3 | 0.5 | Large reasoning model (e.g., o1-preview) |
| **Drafting Blogs** | 0.7 | 0.9 | Standard chat model |
| **Script Refactoring** | 0.2 | 0.2 | Coding-specialized |
