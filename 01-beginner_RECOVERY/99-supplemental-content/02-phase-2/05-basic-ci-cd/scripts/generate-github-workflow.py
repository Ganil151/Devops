"""
GitHub Actions Workflow Generator
Description: Generates basic main.yml for CI/CD.
"""

import os

TEMPLATE = """name: CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Language
      uses: actions/setup-{Language}@v3
      with:
        {Lang}-version: '{Version}'
        
    - name: Install Dependencies
      run: {InstallCmd}
      
    - name: Run Tests
      run: {TestCmd}
"""

def generate_workflow(lang):
    config = {}
    if lang == "python":
        config = {"Language": "python", "Lang": "python", "Version": "3.10", "InstallCmd": "pip install -r requirements.txt", "TestCmd": "pytest"}
    elif lang == "node":
        config = {"Language": "node", "Lang": "node", "Version": "18.x", "InstallCmd": "npm install", "TestCmd": "npm test"}
    elif lang == "java":
        config = {"Language": "java", "Lang": "java", "Version": "17", "InstallCmd": "mvn install -DskipTests", "TestCmd": "mvn test"}
    else:
        print("Unsupported language.")
        return

    content = TEMPLATE.format(**config)
    
    os.makedirs(".github/workflows", exist_ok=True)
    with open(".github/workflows/main.yml", "w") as f:
        f.write(content)
        
    print(f"Generated .github/workflows/main.yml for {lang}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python generate-github-workflow.py [python|node|java]")
    else:
        generate_workflow(sys.argv[1])
