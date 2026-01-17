#!/bin/bash
# -----------------------------------------------------------------------------
# Name: ci_cd_skeleton.sh
# Description: A logical walkthrough of a CI/CD pipeline flow.
# Use this to understand the sequence of events in a professional pipeline.
# -----------------------------------------------------------------------------

set -e # Exit on any failure

echo "[CI] Starting Pipeline..."

# 1. BUILD STAGE
echo -e "\n--- [BUILD] ---"
echo "LOG: Compiling source code..."
# Example: npm install / mvn package / go build
echo "SUCCESS: Artifact created (app.v1.0.tar.gz)"

# 2. TEST STAGE
echo -e "\n--- [TEST] ---"
echo "LOG: Running Unit Tests..."
# Example: py.test / jest
echo "LOG: Running Security Scan (TruffleHog)..."
echo "SUCCESS: All tests passed."

# 3. SCAN STAGE
echo -e "\n--- [SCAN] ---"
echo "LOG: Checking code quality (SonarQube)..."
echo "SUCCESS: Quality gate passed (A-Score)."

# 4. DEPLOY STAGE
echo -e "\n--- [DEPLOY] ---"
echo "LOG: Deploying to Staging environment..."
# Example: terraform apply
echo "SUCCESS: App is live at staging.myapp.com"

echo -e "\n[CI/CD] Pipeline Finished Successfully!"
