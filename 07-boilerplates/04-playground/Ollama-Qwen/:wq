#!/usr/bin/env python3
"""
Ollama UX Audit Wrapper
Connects local Ollama instance to the Principal AI Engineer Audit Framework (v3.1.0)
"""

import requests
import json
import re
import sys
import time

# --- CONFIGURATION (From Turn 1 Meta Data) ---
AUDIT_CONFIG = {
    "version": "3.1.0",
    "model": "qwen2.5",
    "ollama_host": "http://localhost:11434",
    "system_instruction": "You are an expert AI Assistant Developer. Your task is to audit interaction logs, persona prompts, and tool-calling schemas to identify 'robotic' friction, intent misalignment, and context-window failures.",
    "template": """### ROLE
As an {{persona}}, perform a UX and technical audit on the following assistant interaction: {{input_data}}.

### STEPS
1. Identify points where the assistant failed to grasp the user's implicit intent.
2. List exactly {{issue_count}} friction points (e.g., wordiness, lack of proactive help).
3. Provide a refined System Prompt or Tool Schema snippet to fix the behavior.

### OUTPUT FORMAT
Return the audit in a JSON object with keys: 'ux_friction_score', 'intent_gaps', and 'persona_refinement_plan'. """
}

def check_ollama_ready():
    """Ping Ollama to ensure service is up and model is available."""
    try:
        response = requests.get(f"{AUDIT_CONFIG['ollama_host']}/api/tags", timeout=5)
        if response.status_code == 200:
            models = [m['name'] for m in response.json().get('models', [])]
            if any(AUDIT_CONFIG['model'] in m for m in models):
                return True
            else:
                print(f"⚠️  Model '{AUDIT_CONFIG['model']}' not found. Available: {models}")
                return False
        return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to Ollama. Ensure 'ollama serve' is running.")
        return False

def extract_json(text):
    """Robustly extract JSON from LLM response (handles markdown wrappers)."""
    # Try direct load first
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    
    # Regex to find JSON block
    match = re.search(r'```json\s*(.*?)\s*```', text, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError:
            pass
    
    # Fallback: Find first { and last }
    start = text.find('{')
    end = text.rfind('}')
    if start != -1 and end != -1:
        try:
            return json.loads(text[start:end+1])
        except json.JSONDecodeError:
            pass
            
    return None

def run_audit(interaction_log, issue_count=3):
    """Send interaction log to Ollama for audit."""
    # Populate Template
    prompt = AUDIT_CONFIG['template'].replace(
        "{{persona}}", "Principal AI Product & UX Engineer"
    ).replace(
        "{{input_data}}", interaction_log
    ).replace(
        "{{issue_count}}", str(issue_count)
    )

    payload = {
        "model": AUDIT_CONFIG['model'],
        "prompt": prompt,
        "system": AUDIT_CONFIG['system_instruction'],
        "stream": False,
        "options": {
            "temperature": 0.7,
            "top_p": 0.9
        }
    }

    print(f"⏳ Sending audit request to {AUDIT_CONFIG['model']}...")
    start_time = time.time()
    
    try:
        response = requests.post(
            f"{AUDIT_CONFIG['ollama_host']}/api/generate",
            json=payload,
            timeout=120  # Long timeout for large contexts
        )
        response.raise_for_status()
        result_text = response.json().get('response', '')
        
        elapsed = time.time() - start_time
        print(f"✅ Response received in {elapsed:.2f}s")
        
        audit_json = extract_json(result_text)
        
        if audit_json:
            return audit_json
        else:
            print("❌ Failed to parse JSON from model output.")
            print("Raw Output:", result_text[:500])
            return None
            
    except requests.exceptions.RequestException as e:
        print(f"❌ API Error: {e}")
        return None

def main():
    print(f"🔍 === UX Audit Tool v{AUDIT_CONFIG['version']} ===\n")
    
    # 1. System Check
    if not check_ollama_ready():
        sys.exit(1)
        
    # 2. Input Collection
    print("📝 Paste the conversation log to audit (end with '---' on a new line):")
    lines = []
    while True:
        line = input()
        if line.strip() == '---':
            break
        lines.append(line)
    
    interaction_log = "\n".join(lines)
    if not interaction_log.strip():
        print("⚠️  No input provided. Exiting.")
        sys.exit(0)
        
    # 3. Execution
    audit_result = run_audit(interaction_log)
    
    # 4. Output
    if audit_result:
        print("\n📊 === AUDIT RESULTS ===")
        print(json.dumps(audit_result, indent=2))
        
        # Save to file for history
        with open("audit_report.json", "w") as f:
            json.dump(audit_result, f, indent=2)
        print("\n💾 Report saved to 'audit_report.json'")
    else:
        print("\n❌ Audit failed. Check logs above.")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n🛑 Audit interrupted.")
        sys.exit(130)
