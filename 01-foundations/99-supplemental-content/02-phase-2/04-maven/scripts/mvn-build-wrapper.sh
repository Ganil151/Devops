#!/bin/bash
# Maven Build Wrapper
# Description: Standardizes build process
# Author: Senior DevOps Engineer

BASE_DIR=${1:-"."}

echo "Starting Maven Build..."

if [ ! -f "$BASE_DIR/pom.xml" ]; then
    echo "Error: pom.xml not found using '$BASE_DIR'"
    exit 1
fi

cd "$BASE_DIR"

echo "[1] Cleaning..."
mvn clean

echo "[2] Compiling..."
mvn compile

echo "[3] Running Tests..."
mvn test

echo "[4] Packaging..."
mvn package -DskipTests

if [ $? -eq 0 ]; then
    echo "Build Success! Artifacts in $BASE_DIR/target"
else
    echo "Build Failed."
    exit 1
fi
