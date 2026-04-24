import os
import re
import sys
from pathlib import Path

# --- Configuration ---
# Modules to examine
TARGET_EXT = ".py"
# Root directory (one level up from this script's location)
ROOT_DIR = Path(__file__).resolve().parent.parent

# --- Patterns ---
SECURITY_RISKS = {
    "eval()": r"eval\(",
    "exec()": r"exec\(",
    "shell=True (Injection Risk)": r"shell\s*=\s*True",
}

STYLE_VIOLATIONS = {
    "Tab Indentation (PEP 8 requires 4 spaces)": r"^\t+",
    "camelCase Variable (PEP 8 requires snake_case)": r"^[a-z]+[A-Z][a-zA-Z0-9]*\s*=",
    "Shadowing Built-in 'list'": r"list\s*=",
    "Shadowing Built-in 'dict'": r"dict\s*=",
}

def lint_file(file_path):
    violations = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.readlines()
            
            # 1. Logic & Security Checks
            for line_no, line in enumerate(content, 1):
                clean_line = line.strip()
                
                # Check Security
                for risk_name, pattern in SECURITY_RISKS.items():
                    if re.search(pattern, clean_line):
                        violations.append(f"[‼️ SECURITY] Line {line_no}: Found {risk_name}")
                
                # Check Style
                for style_name, pattern in STYLE_VIOLATIONS.items():
                    if re.search(pattern, line): # Use 'line' to check for leading tabs
                        violations.append(f"[⚠️ STYLE] Line {line_no}: {style_name}")

            # 2. Documentation Check (Function Docstrings)
            raw_text = "".join(content)
            functions = re.findall(r"def\s+(\w+)\(.*\):", raw_text)
            for func in functions:
                if not re.search(rf"def\s+{func}\(.*\):\s+\n\s+['\"]{{3}}", raw_text):
                    if not func.startswith("_"): # Ignore internal helpers
                        violations.append(f"[📝 DOCS] Function '{func}' is missing a docstring.")

    except Exception as e:
        violations.append(f"[❌ ERROR] Could not read file: {e}")
    
    return violations

def main():
    # Force UTF-8 encoding for Windows terminals
    if sys.platform == "win32":
        import io
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

    print("="*60)
    print("🚀 SRE Automation Linter: Quality & Security Audit")
    print("="*60)
    print(f"Scanning Root: {ROOT_DIR}\n")
    
    total_files = 0
    total_violations = 0
    
    # Walk the directory
    for root, dirs, files in os.walk(ROOT_DIR):
        # Ignore virtual envs and hidden dirs
        if any(d in root for d in ["venv", ".git", "__pycache__", ".lessenv"]):
            continue
            
        for file in files:
            if file.endswith(TARGET_EXT):
                file_path = Path(root) / file
                rel_path = file_path.relative_to(ROOT_DIR)
                
                issues = lint_file(file_path)
                total_files += 1
                
                if issues:
                    print(f"📄 {rel_path}")
                    for issue in issues:
                        print(f"   {issue}")
                    print("-" * 30)
                    total_violations += len(issues)

    print("\n" + "="*60)
    print(f"📊 REPORT SUMMARY")
    print(f"Files Audited: {total_files}")
    print(f"Total Violations: {total_violations}")
    print("="*60)
    
    if total_violations > 0:
        print("\nACTION REQUIRED: Please address style and security flags to meet SRE standards.")
        sys.exit(1)
    else:
        print("\n✅ SUCCESS: All files passed the SRE Best Practices audit!")
        sys.exit(0)

if __name__ == "__main__":
    main()
