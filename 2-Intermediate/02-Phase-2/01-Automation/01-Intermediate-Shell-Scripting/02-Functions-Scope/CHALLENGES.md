# 🛠️ Function Scoping Challenges

## Challenge 1: The Logger
Create a script with a `log` function.
1.  It handles 2 arguments: `level` (INFO/ERROR) and `message`.
2.  If `level` is ERROR, print to Stderr.
3.  Include a timestamp.
4.  **Critically**: Use `local` variables so arguments don't leak.

## Challenge 2: Shadowing Test
1.  Define a global variable `STATUS="OK"`.
2.  Create a function `check_status` that:
    - Defines a `local STATUS="ERROR"`.
    - Prints `$STATUS`.
3.  Call the function.
4.  Print `$STATUS` *after* the function call.
5.  Verify the global variable was **not** changed.
