#!/bin/bash

set -e

echo "==========================================="
echo "     JENKINS DIAGNOSTICS & AUTO-FIX TOOL    "
echo "==========================================="

# -------- 1. Check Jenkins service ---------
echo -e "\n[1] Checking Jenkins service..."
if systemctl list-unit-files | grep -q jenkins; then
    systemctl status jenkins >/dev/null 2>&1 && STATUS="running" || STATUS="stopped"
    echo "Jenkins service detected: $STATUS"

    if [[ "$STATUS" == "stopped" ]]; then
        echo "[+] Starting Jenkins..."
        sudo systemctl start jenkins
        sudo systemctl enable jenkins
    fi
else
    echo "ERROR: Jenkins is not installed on this system!"
    exit 1
fi


# -------- 2. Check Jenkins port binding ---------
echo -e "\n[2] Checking if Jenkins is listening on port 8080..."
PORT_OUTPUT=$(sudo ss -tulpn | grep :8080 || true)

if [[ -z "$PORT_OUTPUT" ]]; then
    echo "ERROR: Jenkins is NOT listening on port 8080!"
    echo "Check Jenkins logs:"
    echo "    sudo journalctl -u jenkins -f"
else
    echo "[+] Port 8080 detected:"
    echo "$PORT_OUTPUT"

    if echo "$PORT_OUTPUT" | grep -q "127.0.0.1:8080"; then
        echo "[-] Jenkins is bound to localhost ONLY — fixing..."

        CONFIG_FILE="/etc/sysconfig/jenkins"

        if [[ -f "$CONFIG_FILE" ]]; then
            sudo sed -i 's/^JENKINS_LISTEN_ADDRESS=.*/JENKINS_LISTEN_ADDRESS=""/' "$CONFIG_FILE"
            echo "[+] Updated Jenkins listen address"
            
            echo "[+] Restarting Jenkins..."
            sudo systemctl restart jenkins
        else
            echo "ERROR: Cannot find Jenkins config file: $CONFIG_FILE"
        fi
    else
        echo "[+] Jenkins correctly listening on 0.0.0.0"
    fi
fi


# -------- 3. Check OS Firewall ---------
echo -e "\n[3] Checking OS firewall..."

if systemctl is-active --quiet firewalld; then
    echo "[+] firewalld active – making sure port 8080 is open..."
    sudo firewall-cmd --permanent --add-port=8080/tcp >/dev/null 2>&1 || true
    sudo firewall-cmd --reload
    echo "[+] Port 8080 allowed via firewalld"
elif command -v ufw >/dev/null 2>&1; then
    echo "[+] ufw detected – ensuring port 8080 is allowed..."
    sudo ufw allow 8080/tcp
    sudo ufw reload
else
    echo "[*] No OS firewall detected (good)"
fi


# -------- 4. Check Docker Jenkins ---------
echo -e "\n[4] Checking if Jenkins is running inside Docker..."

if docker ps --format '{{.Image}}' | grep -qi jenkins; then
    echo "[!] Jenkins is running in Docker"
    echo "Checking port mapping..."
    
    docker ps | grep jenkins

    if ! docker ps | grep -q "8080->8080"; then
        echo "ERROR: Docker Jenkins does NOT expose port 8080"
        echo "Fix example:"
        echo "    docker run -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts"
    else
