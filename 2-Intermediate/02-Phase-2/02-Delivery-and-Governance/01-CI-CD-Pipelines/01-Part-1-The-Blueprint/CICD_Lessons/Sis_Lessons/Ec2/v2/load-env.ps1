# This script reads a `.env` file, parses its contents, and sets environment variables in the current session.

# `Get-Content .env` reads the contents of the `.env` file line by line.
# Each line in the `.env` file is expected to be in the format `KEY=VALUE`.
Get-Content .env | ForEach-Object {
    # For each line in the `.env` file, this block processes the line.
    
    # `$_` represents the current line being processed.
    # The `.Split('=')` method splits the line into two parts: the key and the value, using the `=` character as the delimiter.
    # `$key` will store the part before the `=`, and `$value` will store the part after the `=`.
    $key, $value = $_.Split('=')

    # `[System.Environment]::SetEnvironmentVariable()` is used to set an environment variable in the current session.
    # `$key.Trim()` removes any leading or trailing whitespace from the key.
    # `$value.Trim()` removes any leading or trailing whitespace from the value.
    [System.Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim())
}


# For Linux base systems:
#!/bin/bash

# This script reads a `.env` file, parses its contents, and exports the key-value pairs as environment variables.

# Check if the `.env` file exists
# if [[ ! -f .env ]]; then
#     echo "Error: .env file not found!"
#     exit 1
# fi

# # Read the `.env` file line by line
# while IFS='=' read -r key value; do
#     # Trim leading and trailing whitespace from the key and value
#     key=$(echo "$key" | xargs)
#     value=$(echo "$value" | xargs)

#     # Skip empty lines or lines that start with `#` (comments)
#     if [[ -n $key && $key != "#"* ]]; then
#         # Export the key-value pair as an environment variable
#         export "$key=$value"
#         echo "Exported: $key=${value:-<value_hidden>}"
#     fi
# done < .env

# echo "Environment variables loaded successfully."