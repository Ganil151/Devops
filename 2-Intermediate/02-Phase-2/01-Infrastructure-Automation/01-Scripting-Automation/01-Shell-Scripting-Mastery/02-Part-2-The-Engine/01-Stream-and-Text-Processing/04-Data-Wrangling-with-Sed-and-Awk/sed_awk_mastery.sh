#!/usr/bin/env bash
# Topic: Data Wrangling with Sed and Awk
# File: 04-Data-Wrangling-with-Sed-and-Awk/sed_awk_mastery.sh

set -euo pipefail

# 1. Create Mock CSV Data
CSV_DATA="ID,Service,Uptime(s),Status
101,Nginx,5400,UP
102,Postgres,36000,UP
103,Redis,250,DOWN
104,Auth-Service,0,CRITICAL"

echo "📝 Processing Raw Service Metrics..."

# 2. AWK: Calculate Average Uptime for 'UP' services
echo -n "  - Average Uptime (Healthy): "
echo "$CSV_DATA" | awk -F',' '$4 == "UP" { total += $3; count++ } END { if (count > 0) print total/count "s"; else print "N/A" }'

# 3. SED: Transform Status codes to Emojis and Mask Critical IDs
echo -e "\n📊 Cleaned Status Report:"
echo "$CSV_DATA" | sed '1d' | sed -E 's/UP/✅/; s/DOWN/❌/; s/CRITICAL/🔥/' | \
awk -F',' '{ printf "  - [%-12s] Status: %s\n", $2, $4 }'

# 4. Filter: Find high-uptime services (>10,000s)
echo -e "\n🏆 High Availability Services (Uptime > 10ks):"
echo "$CSV_DATA" | awk -F',' '$3 > 10000 { print "  - " $2 " (" $3 "s)" }'
