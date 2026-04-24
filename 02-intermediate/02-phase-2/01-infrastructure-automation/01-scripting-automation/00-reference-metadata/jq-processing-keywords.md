# 🔍 Reference: JQ Processing Keywords

`jq` is the "Swiss Army Knife" for JSON processing in the terminal. In Cloud automation, where everything is an API response, `jq` is mandatory.

---

## 🏗️ Basic Selectors

### `.` (The Identity Operator)
*   **Definition**: Represents the incoming JSON object. `jq '.'` simply pretty-prints the entire input.

### `.[ ]` (Iteration)
*   **Definition**: Iterates over an array or the values of an object.
*   **Example**: `.items[]` returns each element in the `items` list as a separate stream of objects.

---

## 🛠️ Filter & Transform Keywords

### `select(...)`
*   **Definition**: Filters a stream of objects. Only objects that return "true" for the condition are passed through.
*   **DevOps Example**: `select(.state == "running")`.

### `map(...)`
*   **Definition**: Applies a filter to every element in an array and returns the results as a *new* array.

### `-r` (Raw Output)
*   **Definition**: Removes quotes from string outputs.
*   **DevOps Why**: Essential when you need to pass a value (like an `InstanceID`) directly into another shell command or variable.

### `-c` (Compact Output)
*   **Definition**: Minifies the JSON into a single line.
*   **DevOps Why**: Perfect for log shipping or passing large payloads to CLI tools.

---

## 📈 Advanced Operators

### `length`
*   **Definition**: Returns the size of an array, object, or string. Used for counting resources.

### `|` (The Pipe)
*   **Definition**: Pass the output of one selector/filter to the next.
*   **Example**: `[.[] | select(.active)] | length` (Count all active items).

---

## 🎙️ Staff Interview context
*   **"How do you handle a JSON response that is too large for memory?"**
    *   *Answer*: Use `jq -c` to process objects as a stream (JSON lines) rather than one massive array, and use `grep` or `awk` for initial filtering if necessary.
