#!/bin/bash
# Local Pipeline Runner
# Simulates CI steps locally based on language detection

echo "Detecting project type..."

if [ -f "requirements.txt" ]; then
    echo "Python project detected."
    
    echo "[1] Installing Dependencies..."
    pip install -r requirements.txt
    
    echo "[2] Linting..."
    flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
    
    echo "[3] Testing..."
    pytest

elif [ -f "package.json" ]; then
    echo "Node.js project detected."
    
    echo "[1] Installing..."
    npm install
    
    echo "[2] Testing..."
    npm test

elif [ -f "pom.xml" ]; then
    echo "Java/Maven project detected."
    
    echo "[1] Build & Test..."
    mvn verify

else
    echo "Unknown project type."
    exit 1
fi
