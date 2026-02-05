#!/usr/bin/env bash
# Topic: Advanced Argument Parsing with Getopts
# File: 02-Advanced-Argument-Parsing-Getopts/getopts_cli.sh

set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") -e <env> [-r <region>] [-f] [-h]

Options:
  -e  Environment (Required: dev|staging|prod)
  -r  Target Region (Default: us-east-1)
  -f  Force execution (Optional)
  -h  Display help
EOF
    exit 1
}

# 1. Initialize variables
ENV=""
REGION="us-east-1"
FORCE=false

# 2. Parse flags
while getopts "e:r:fh" opt; do
    case "$opt" in
        e) ENV="$OPTARG" ;;
        r) REGION="$OPTARG" ;;
        f) FORCE=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# 3. Guard Clause: Mandatory Argument Check
if [[ -z "$ENV" ]]; then
    echo "❌ Error: Environment (-e) is required."
    usage
fi

# 4. Logic block
echo "🚀 Deployment Summary:"
echo "  - Environment: $ENV"
echo "  - Region:      $REGION"
echo "  - Force Mode:  $FORCE"

if [[ "$ENV" == "prod" && "$FORCE" == "false" ]]; then
    echo "⚠️ WARNING: You are deploying to PROD without --force. Aborting."
    exit 1
fi

echo "✅ Proceeding with deployment..."
