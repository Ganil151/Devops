# 🛠️ Argument Parsing Challenges

## Challenge 1: The Universal Deploy Tool

**Objective**: Create a script named `deploy_tool.sh` that accepts an environment (`-e`), a version (`-v`), and a dry-run flag (`-d`).

**Requirements**:
1.  **Usage**: Implement a `usage` function that prints help if no arguments are passed.
2.  **Getopts Loop**: Parse `-e`, `-v`, and `-d`.
    *   `-e`: Required. Sets `$TARGET_ENV`.
    *   `-v`: Optional. Sets `$VERSION` (default to "latest").
    *   `-d`: Boolean. Sets `$DRY_RUN` to "true".
3.  **Missing Arg**: If `-e` is missing after parsing, print an error and usage.
4.  **Execute**: Print "Deploying version $VERSION to $TARGET_ENV" (or "Would deploy..." if dry-run).

## Challenge 2: The Multi-Command Tool
Create a script that acts like git: `tool.sh [command] [flags]`.
1.  Check `$1`. If it is `start`, `stop`, or `restart`, handle it.
2.  Inside each command block (or function), use `getopts` or a loop to parse specific flags for *that* command.
    *   `tool.sh start -f` (Force start)
    *   `tool.sh stop -t 10` (Timeout 10s)
