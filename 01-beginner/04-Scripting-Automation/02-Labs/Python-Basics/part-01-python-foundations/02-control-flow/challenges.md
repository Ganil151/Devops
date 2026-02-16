# 🧪 Control Flow Labs: Decision Logic Challenges

Apply your knowledge of conditionals to solve these real-world DevOps scenarios.

---

### 📝 Lab 1: Log Level Filter
Create a script that takes a "Level" input (DEBUG, INFO, ERROR) and prints only the relevant message.

**Requirements**:
1.  Ask the user for their desired log level.
2.  Use `if/elif/else` or `match-case`.
3.  If the level is invalid, print "Unknown Log Level."

---

### 🚀 Lab 2: Deployment Validator
Ensure a safe environment before "deploying" a mock application.

**Requirements**:
1.  Check if 3 variables exist (e.g., `APP_PORT`, `DB_URL`, `API_TOKEN`).
2.  Use logical operators (`and`) to ensure ALL are present.
3.  If any are missing, identify which one or print a generic error.

---

### 🔌 Lab 3: Port Range Categorizer
Network ports are divided into categories. Write a script to categorize an input port number.

**Requirements**:
- **0 - 1023**: Well-known Ports
- **1024 - 49151**: Registered Ports
- **49152 - 65535**: Dynamic/Private Ports
- **Others**: "Invalid Port Number"

**Challenge**: Use `range()` checks within your conditionals for maximum efficiency.
