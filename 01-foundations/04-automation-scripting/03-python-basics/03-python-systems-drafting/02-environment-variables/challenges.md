# 🎯 Environment Variables: The Secret Vault Challenges

> **"Infrastructure config is only as safe as your weakest variable. These challenges test your ability to build secure, validated, and portable configuration systems."**

---

## 🏆 Challenge 1: The Fail-Fast Validator
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 20 minutes

### Objective
Build a script that refuses to start if critical environment variables are missing.

### Requirements
- Create a list of `REQUIRED_VARS = ["DB_HOST", "DB_PASSWORD", "API_KEY"]`.
- Loop through the list and check if they exist in `os.environ`.
- If any are missing, print a detailed error message: `❌ Missing required variable: [NAME]` and exit with code `1`.
- If all are present, print `✅ System Ready`.

---

## 🏆 Challenge 2: The Masking Config Logger
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Safely log the current configuration without leaking secrets.

### Requirements
- Load all variables starting with `APP_` or `DB_` into a dictionary.
- Create a function `mask_config(config_dict)` that replaces any values whose keys contain "PASSWORD", "SECRET", or "KEY" with `[REDACTED]`.
- Print the masked configuration as a pretty-printed JSON string.

---

## 🏆 Challenge 3: The Boolean Type-Enforcer
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 20 minutes

### Objective
Properly parse boolean environment variables (avoiding the common "all strings are True" trap).

### Requirements
- Read an environment variable `DEBUG`.
- Map the following strings to `True`: `true`, `1`, `yes`, `on`.
- Map anything else (or missing) to `False`.
- Print: `Debug status: [True/False]`.

---

## 🏆 Challenge 4: Prefix-Based Dynamic Loader
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Dynamically load specific groups of environment variables into sub-dictionaries.

### Requirements
- Create variables like `DB_HOST`, `DB_PORT`, `STORAGE_BUCKET`, `STORAGE_REGION`.
- Build a function `load_prefixed_config(prefix)` that returns a dictionary of all variables starting with that prefix, with the prefix removed.
- Example: `load_prefixed_config("DB_")` returns `{"HOST": "...", "PORT": "..."}`.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Fail-Fast Validator
- [ ] Challenge 2: Masking Config Logger
- [ ] Challenge 3: Boolean Type-Enforcer
- [ ] Challenge 4: Prefix-Based Dynamic Loader
