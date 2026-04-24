# Lab 02: API Polling & Monitoring

## 🎯 Objective
Create a robust script that polls a web endpoint (e.g., a health check URL) until it returns a "200 OK" status or times out. Implement **Exponential Backoff** to avoid spamming the server.

## 📝 Starter Template (`poll_api.sh`)
```bash
#!/bin/bash

URL="$1"
MAX_RETRIES=5

# TODO: Create a loop that tries to curl the URL
# TODO: If success (HTTP 200), exit 0
# TODO: If fail, sleep for X seconds (where X doubles each time)
# TODO: If MAX_RETRIES reached, exit 1
```

## ✅ Solution (`solution_poll_api.sh`)
```bash
#!/bin/bash
# ==============================================================================
# Script: Smart API Poller
# Usage: ./poll_api.sh <URL>
# ==============================================================================

set -u

URL="${1:?Error: URL argument required}"
MAX_RETRIES=5
WAIT_SECONDS=2

check_endpoint() {
    # Curl with fail-fast (-f), silent (-s), and outputting only status code
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
    
    if [[ "$status" == "200" ]]; then
        return 0
    else
        echo "Status: $status"
        return 1
    fi
}

echo "Starting poll for $URL..."

for ((i=1; i<=MAX_RETRIES; i++)); do
    if check_endpoint; then
        echo "✅ Success: Service is UP!"
        exit 0
    fi
    
    echo "❌ Attempt $i/$MAX_RETRIES failed. Retrying in ${WAIT_SECONDS}s..."
    sleep "$WAIT_SECONDS"
    
    # Exponential Backoff logic: wait = wait * 2
    WAIT_SECONDS=$(( WAIT_SECONDS * 2 ))
done

echo "🚨 Failure: Max retries reached. Service is DOWN."
exit 1
```
