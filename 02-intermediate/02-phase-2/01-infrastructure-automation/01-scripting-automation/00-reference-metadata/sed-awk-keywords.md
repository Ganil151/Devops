# 🧶 Reference: Sed & Awk Keywords

The "Grandfathers" of text processing. While `jq` handles JSON, `sed` and `awk` handle the billions of lines of raw logs, CSVs, and config files found in every system.

---

## ✂️ SED (Stream Editor)

### `s/find/replace/g`
*   **Definition**: The "Substitute" command. Replaces the first occurrence on a line. Adding `g` at the end makes it global (all occurrences on the line).

### `-E` (Extended Regex)
*   **Definition**: Enables modern Regex features like `+`, `?`, and `|`.
*   **DevOps Standard**: Always use `-E` to avoid "backslash-hell" with basic escapes.

### `d` (Delete)
*   **Definition**: Deletes matching lines. `sed '1d' file` deletes the first line (useful for removing CSV headers).

---

## 📊 AWK (Data Extraction & Reporting)

### `-F` (Field Separator)
*   **Definition**: Tells awk what character separates columns. `-F','` is for CSV. Space/Tab is the default.

### `$1, $2, ... $NF`
*   **Definition**: Positional variables for columns. `$1` is the 1st column. `$NF` is a magic variable for the "Last" column.

### `NR` (Number of Records)
*   **Definition**: Keeps track of the current line number.

### `BEGIN { }` and `END { }`
*   **Definition**: Code blocks that run *before* the first line is read and *after* the last line is processed.
*   **Example**: Summing a column in the main loop and printing the total in the `END` block.

---

## 🎙️ Staff Interview context
*   **"When should you use awk instead of a loop in Bash?"**
    *   *Answer*: Reaching for `awk` is faster and more memory-efficient for processing large text files. Bash loops are slow; `awk` is a specialized C-based engine for columnar data.
