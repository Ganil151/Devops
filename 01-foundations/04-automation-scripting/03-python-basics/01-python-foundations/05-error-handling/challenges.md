# Error Handling - DevOps Challenges

## Challenge 1: File Reader Safe Guard
**Scenario**: Read a critical config file, handling missing file permission errors.

**Requirements:**
1. Try to open a file provided as argument.
2. Catch `FileNotFoundError` -> Print "Config missing, using defaults".
3. Catch `PermissionError` -> Print "Access denied".
4. Finally block -> Print "Execution finished".

**Verification:**
```bash
python safe_reader.py /root/secure.conf
```

---

## Challenge 2: JSON Validator
**Scenario**: Validate user input JSON strings.

**Requirements:**
1. Use `json.loads()` to parse a string.
2. Catch `json.JSONDecodeError`.
3. Print the exact line number/column of the error provided by the exception.

**Verification:**
```bash
python validator.py "{'invalid': json}"
```

---

## Challenge 3: Custom Exception (Deployment)
**Scenario**: Stop script if validation fails.

**Requirements:**
1. Define class `DeploymentError(Exception)`.
2. Function `deploy()` raises this error if `disk_space < 10GB`.
3. Main block catches it and prints "Deployment Aborted".

**Verification:**
```bash
python deploy.py
```
