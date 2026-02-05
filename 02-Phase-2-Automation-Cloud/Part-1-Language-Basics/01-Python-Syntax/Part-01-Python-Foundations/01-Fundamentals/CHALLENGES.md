# 🎯 Python Fundamentals - Challenges

## 📋 Overview
These challenges test your understanding of Python's core syntax, variables, operators, and basic I/O operations. Each challenge builds foundational skills essential for DevOps automation.

---

## 🏆 Challenge 1: Environment Inspector
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Create a script that displays comprehensive system and Python environment information.

### Requirements
- Display Python version
- Show current working directory
- Print system platform information
- Display environment variables (at least 5)
- Show current user

### Success Criteria
```python
# Expected output format:
Python Version: 3.11.x
Working Directory: /path/to/current/dir
Platform: linux/darwin/win32
Environment Variables:
  PATH: ...
  HOME: ...
  USER: ...
```

### Hints
- Use `sys.version`, `os.getcwd()`, `sys.platform`
- Explore `os.environ` dictionary
- Consider `getpass.getuser()` for username

---

## 🏆 Challenge 2: Configuration Validator
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 20 minutes

### Objective
Build a script that validates configuration values with type checking and range validation.

### Requirements
- Accept user input for: server port, timeout (seconds), max retries
- Validate port is between 1-65535
- Validate timeout is positive integer
- Validate max retries is between 1-10
- Display validation errors with helpful messages
- Print final validated configuration

### Success Criteria
```python
# Example interaction:
Enter server port: 8080
Enter timeout (seconds): 30
Enter max retries: 3

✓ Configuration validated successfully!
Server Port: 8080
Timeout: 30s
Max Retries: 3
```

### Hints
- Use `int()` with try-except for type conversion
- Implement range checks with if statements
- Consider creating a validation function

---

## 🏆 Challenge 3: String Formatter Pro
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 25 minutes

### Objective
Create a utility that formats deployment information using multiple string formatting techniques.

### Requirements
- Accept: service name, version, environment, timestamp
- Format output using:
  - Old-style `%` formatting
  - `.format()` method
  - f-strings (Python 3.6+)
- Display all three formatted versions
- Include proper alignment and padding

### Success Criteria
```python
# Example output:
Service: nginx | Version: 1.21.0 | Env: production | Time: 2026-01-26 07:42:05

Old Style: Service: nginx, Version: 1.21.0, Environment: production
Format Method: Service: nginx     | Version: 1.21.0  | Env: production
F-String: 🚀 Deploying nginx v1.21.0 to production at 2026-01-26 07:42:05
```

### Hints
- Use `%-formatting`: `"Service: %s" % service_name`
- Use `.format()`: `"Service: {:<10}".format(service_name)`
- Use f-strings: `f"Service: {service_name}"`

---

## 🏆 Challenge 4: Arithmetic Calculator
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Build a simple calculator that performs basic arithmetic operations.

### Requirements
- Accept two numbers from user
- Perform: addition, subtraction, multiplication, division, modulo, exponentiation
- Handle division by zero gracefully
- Display results in a formatted table

### Success Criteria
```python
# Example output:
Enter first number: 10
Enter second number: 3

Results:
Addition:       10 + 3 = 13
Subtraction:    10 - 3 = 7
Multiplication: 10 * 3 = 30
Division:       10 / 3 = 3.33
Modulo:         10 % 3 = 1
Exponentiation: 10 ** 3 = 1000
```

### Hints
- Use `float()` for number conversion
- Check for zero before division
- Use f-strings for alignment

---

## 🏆 Challenge 5: Type Conversion Master
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 20 minutes

### Objective
Create a script that demonstrates type conversions and handles conversion errors.

### Requirements
- Accept a string input
- Attempt conversions to: int, float, bool, list
- Handle conversion errors gracefully
- Display successful conversions with type information
- Show which conversions failed and why

### Success Criteria
```python
# Example with input "42":
Original: "42" (type: str)
✓ int: 42 (type: int)
✓ float: 42.0 (type: float)
✓ bool: True (type: bool)
✓ list: ['4', '2'] (type: list)

# Example with input "hello":
Original: "hello" (type: str)
✗ int: invalid literal for int() with base 10: 'hello'
✗ float: could not convert string to float: 'hello'
✓ bool: True (type: bool)
✓ list: ['h', 'e', 'l', 'l', 'o'] (type: list)
```

### Hints
- Use try-except blocks for each conversion
- Use `type()` to display type information
- Remember: non-empty strings are always `True` when converted to bool

---

## 🏆 Challenge 6: Variable Scope Explorer
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 30 minutes

### Objective
Demonstrate understanding of variable scope (local, global, nonlocal).

### Requirements
- Create nested functions demonstrating scope
- Show global variable modification
- Demonstrate nonlocal keyword usage
- Include examples of scope shadowing
- Add comments explaining each scope behavior

### Success Criteria
```python
# Script should demonstrate:
1. Global variable accessible in functions
2. Local variable shadowing global
3. nonlocal keyword modifying enclosing scope
4. Scope chain resolution (LEGB rule)
```

### Hints
- Use `global` keyword for global modification
- Use `nonlocal` for enclosing scope modification
- LEGB: Local, Enclosing, Global, Built-in

---

## 🎓 Bonus Challenge: DevOps Config Generator
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Create a comprehensive configuration file generator for a DevOps service.

### Requirements
- Accept multiple configuration parameters (at least 8)
- Validate all inputs with appropriate rules
- Support default values
- Generate a formatted configuration output
- Include metadata (timestamp, generator version)
- Save to file option

### Success Criteria
- Clean, user-friendly input prompts
- Comprehensive validation with helpful error messages
- Professional formatted output
- File save functionality
- Proper error handling

### Example Parameters
- Service name, port, host, environment
- Log level, log file path
- Max connections, timeout
- Enable SSL (yes/no)

---

## 📚 Learning Resources
- [Python Official Tutorial - Variables](https://docs.python.org/3/tutorial/introduction.html)
- [Real Python - Variables and Data Types](https://realpython.com/python-variables/)
- [Python String Formatting](https://realpython.com/python-f-strings/)

---

## ✅ Completion Checklist
- [ ] Challenge 1: Environment Inspector
- [ ] Challenge 2: Configuration Validator
- [ ] Challenge 3: String Formatter Pro
- [ ] Challenge 4: Arithmetic Calculator
- [ ] Challenge 5: Type Conversion Master
- [ ] Challenge 6: Variable Scope Explorer
- [ ] Bonus: DevOps Config Generator

---

**Next**: [Data Structures Challenges →](CHALLENGES.md)
