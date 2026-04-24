---
description: AI Toolkit provides tools for AI/Agent app development
applyTo: '**'
---

## 🤖 AI Toolkit Tools & Best Practices

The following tools are available for AI Agent development, code generation, and evaluation:

### 🛠️ Agent Development

#### `aitk-get_agent_code_gen_best_practices`
- **Purpose**: Best practices, guidance, and steps for any AI Agent development
- **Use When**: 
  - Starting a new AI agent project
  - Optimizing existing agent architecture
  - Implementing multi-turn conversations
  - Designing agent workflows and state management
- **Output**: Step-by-step guidance, code patterns, and architectural recommendations

### 📊 Tracing & Observability

#### `aitk-get_tracing_code_gen_best_practices`
- **Purpose**: Best practices for code generation and operations when working with tracing for AI applications
- **Use When**:
  - Implementing logging and monitoring for AI systems
  - Setting up distributed tracing
  - Debugging agent behavior and API calls
  - Analyzing performance bottlenecks
- **Output**: Tracing implementation patterns, instrumentation guidelines, and operational best practices

### 🧠 Model Guidance

#### `aitk-get_ai_model_guidance`
- **Purpose**: Guidance and best practices for using AI models
- **Use When**:
  - Selecting appropriate models for your task
  - Configuring model parameters
  - Optimizing prompts and context windows
  - Managing token costs and latency
  - Handling model-specific constraints
- **Output**: Model selection criteria, configuration recommendations, and usage patterns

### 📈 Evaluation Planning

#### `aitk-evaluation_planner`
- **Purpose**: Multi-turn conversation guide for clarifying evaluation metrics and test datasets
- **Use When**:
  - Evaluation metrics are unclear or undefined
  - Planning evaluation strategy for your AI application
  - Defining success criteria for agent behavior
  - Designing test datasets
- **Important**: **Call this tool FIRST** when evaluation metrics are unclear
- **Output**: Clarified evaluation metrics, test dataset specifications, and evaluation methodology

### ✅ Evaluation Code Generation

#### `aitk-get_evaluation_code_gen_best_practices`
- **Purpose**: Best practices for evaluation code generation when working on evaluation for AI applications or AI agents
- **Use When**:
  - Writing evaluation code for your agent
  - Implementing metric calculations
  - Setting up test harnesses
  - Automating evaluation pipelines
- **Prerequisite**: Use `aitk-evaluation_planner` first to clarify metrics
- **Output**: Code templates, metric implementations, and evaluation frameworks

### 🏃 Agent Runner & Testing

#### `aitk-evaluation_agent_runner_best_practices`
- **Purpose**: Best practices and guidance for using agent runners to collect responses from test datasets for evaluation
- **Use When**:
  - Running agents against test datasets at scale
  - Collecting and aggregating responses
  - Handling concurrent agent execution
  - Managing test data lifecycle
- **Output**: Runner configuration patterns, batch processing guidance, and result aggregation strategies

---

## 📋 Recommended Workflow

### For New AI Agent Projects:
1. **Start with**: `aitk-get_agent_code_gen_best_practices`
2. **Add Observability**: `aitk-get_tracing_code_gen_best_practices`
3. **Model Selection**: `aitk-get_ai_model_guidance`
4. **Setup Evaluation**: `aitk-evaluation_planner` → `aitk-get_evaluation_code_gen_best_practices`
5. **Test at Scale**: `aitk-evaluation_agent_runner_best_practices`

### For Evaluation-Focused Work:
1. **Clarify Metrics**: `aitk-evaluation_planner` ⭐ (Start here!)
2. **Write Evaluation Code**: `aitk-get_evaluation_code_gen_best_practices`
3. **Run Agent Tests**: `aitk-evaluation_agent_runner_best_practices`
4. **Add Tracing**: `aitk-get_tracing_code_gen_best_practices`

---

## 🔑 Key Principles

- **Evaluation First**: Always clarify what success looks like before building
- **Observable Systems**: Instrument agents with proper tracing from the start
- **Iterative Development**: Use agent runners to validate against test datasets continuously
- **Model-Aware**: Choose models and configurations based on your specific constraints
- **Best Practices**: Follow established patterns for reliability and maintainability

---

## 📝 Usage Notes

- These tools are applicable to all file types and project types (`applyTo: '**'`)
- Tools can be used independently or in combination
- Refer back to these tools throughout your project lifecycle
- Update this file as new tools become available
