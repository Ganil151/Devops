#!/bin/bash
# -----------------------------------------------------------------------------
# Name: advanced_io.sh
# Description: Demonstrates HereDocs and Process Substitution.
# -----------------------------------------------------------------------------

set -u

# 1. Generating a Config File with HereDoc
echo "Generating Nginx Config..."
cat <<EOF > /tmp/nginx_mock.conf
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
}
EOF
echo "File created at /tmp/nginx_mock.conf"

# 2. Process Substitution
# Let's compare two lists of "installed packages" without creating temp files.
echo ""
echo "Comparing Lists..."

# Mocking command output
CMD_A="echo -e 'pkg1\npkg2\npkg3'"
CMD_B="echo -e 'pkg1\npkg4\npkg3'"

# Use diff on specific command outputs
diff <(eval "$CMD_A" | sort) <(eval "$CMD_B" | sort)

echo ""
echo "Diff finished. (If output is empty, they matched)."
