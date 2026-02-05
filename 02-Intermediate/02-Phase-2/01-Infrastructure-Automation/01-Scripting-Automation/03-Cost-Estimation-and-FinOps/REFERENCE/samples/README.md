# 📊 Infracost Automation Samples

This directory contains production-grade samples for automating cost visibility and enforcement.

## 📂 Samples Index

| Sample File | Use Case | Implementation |
| :--- | :--- | :--- |
| [`infracost_cli_pipeline.sh`](./infracost_cli_pipeline.sh) | Standard CLI automation for local or custom CI runners. | Bash |
| [`cost_guardrail.py`](./cost_guardrail.py) | Python wrapper to parse Infracost JSON and enforce logical budget rules. | Python |
| [`usage_metrics.yml`](./usage_metrics.yml) | Defining variable usage (S3, Data Transfer) for accurate pricing. | YAML |
| [`advanced_gha_policy.yml`](./advanced_gha_policy.yml) | Fully automated GitHub Action with diffing and PR commenting. | YAML |

---

### 🚀 Usage Instruction
1. Ensure the `INFRACOST_API_KEY` environment variable is set.
2. For bash scripts, ensure the `infracost` binary is in your PATH.
3. For Python scripts, use `pip install json` (standard library).
