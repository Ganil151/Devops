# 📟 Reference: Argument Parsing Keywords

Standardizing how users interact with your scripts is vital for scaling automation. Using named flags instead of positional arguments reduces human error.

---

## 🛠️ The `getopts` Engine

### `getopts`
*   **Definition**: A built-in Bash utility used to parse short options (e.g., `-e`, `-p`).
*   **The Optstring**: A string containing the allowed flag characters. A colon `:` after a letter (e.g., `e:`) indicates that the flag requires an argument.

### `$OPTARG`
*   **Definition**: A magic variable that holds the value passed to a flag. If `-e prod` is passed, `$OPTARG` becomes `prod`.

### `$OPTIND`
*   **Definition**: The "Option Index." It tracks the position of the next argument to be processed.
*   **Usage**: Used after the `getopts` loop with `shift $((OPTIND-1))` to remove the flags and leave only the remaining "positional" arguments.

---

## 🏗️ Design Patterns

### `usage()` Function
*   **Definition**: A standard function that prints a help manual using a **Here-Doc** (`cat <<EOF`).
*   **Standard**: Always exit with code `1` if the usage is shown due to an error, and code `0` if requested via `-h`.

### `case "$opt" in`
*   **Definition**: The multi-way branch used to process flags. 
*   **The Wildcard `*)`**: Acts as a catch-all for invalid flags, triggering the `usage()` menu to guide the user.

---

## 🎙️ Staff Interview context
*   **"Why use getopts instead of manually checking $1, $2, etc?"**
    *   *Answer*: `getopts` handles flag grouping (e.g., `-af` same as `-a -f`) and allows arguments to be passed in any order. It makes your script feel like a professional Linux tool.
