#!/bin/bash

# boilerplate_log_processor.sh - Real-time log stream processing

set -euo pipefail

readonly ERROR_FILE="errors.log"
readonly WARN_FILE="warnings.log"
readonly INFO_FILE="info.log"

while IFS= read -r line; do
    case "$line" in
        *ERROR*)
            echo "$line" >> "$ERROR_FILE"
            echo "$line" | mail -s "Error Alert" ops@example.com
            ;;
        *WARN*)
            echo "$line" >> "$WARN_FILE"
            ;;
        *)
            echo "$line" >> "$INFO_FILE"
            ;;
    esac
done

# Usage: tail -f app.log | ./boilerplate_log_processor.sh
