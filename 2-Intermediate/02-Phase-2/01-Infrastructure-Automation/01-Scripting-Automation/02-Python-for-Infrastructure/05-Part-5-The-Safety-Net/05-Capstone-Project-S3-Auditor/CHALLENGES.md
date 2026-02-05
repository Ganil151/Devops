# 🏆 Capstone Challenge: S3 Guardian

**Objective**: Build a full-featured CLI tool that audits AWS S3 security.

## Requirements

1.  **CLI Interface**: Use `argparse` to accept:
    - `--profile`: AWS Credential Profile.
    - `--region`: Specific region to scan.
    - `--fix`: (Optional) Auto-enable encryption if missing.

2.  **Audit Checks**:
    - **Encryption**: Is Default Encryption enabled?
    - **Public Access**: Is "Block Public Access" enabled?
    - **Versioning**: Is Versioning enabled? (Critical for Ransomware protection).
    - **Tags**: Does it have the required tag `Owner`?

3.  **Reporting**:
    - Output a JSON structure:
      ```json
      [
        {"bucket": "finance-logs", "score": 100, "issues": []},
        {"bucket": "temp-data", "score": 50, "issues": ["No Versioning", "Public"]}
      ]
      ```

4.  **Dry Run**:
    - If `--fix` is passed, strictly DO NOT apply changes unless user confirms with "Y".

## Evaluation Criteria
- **Modularity**: Are checks separated into functions?
- **Error Handling**: Does the script crash if it hits a bucket access denied error? (It shouldn't).
- **Type Hinting**: Are standard types used?
