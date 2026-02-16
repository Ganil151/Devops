"""
Fundamentals Demo: System Resource Monitor
------------------------------------------
This script demonstrates the core pillars of Python Fundamentals:
1. Type Hinting (PEP 484)
2. String Manipulation (Parsing raw data)
3. Control Flow (Guard Clauses & Logical Ladders)
4. Data Structures (Lists & Dictionaries)
"""

from typing import List, Dict

# --- 1. Variables & Constants (Global Scope) ---
THRESHOLD_CRITICAL: float = 90.0
THRESHOLD_WARNING: float = 75.0

def analyze_system_logs(raw_logs: str) -> List[Dict[str, str]]:
    """
    Parses raw log strings into a structured object list.
    Demonstrates String Manipulation & Lists.
    """
    structured_data: List[Dict[str, str]] = []
    
    # Fundamentals: .splitlines() handles all OS newline types safely
    for line in raw_logs.strip().splitlines():
        # Parsing: "SERVER_NAME : USAGE"
        if ":" not in line:
            continue
            
        parts = line.split(":")
        
        # Guard Clause: Exit early if data is malformed
        if len(parts) != 2:
            continue
            
        # Clean up whitespace and normalize data
        server_name = parts[0].strip().upper()
        usage_val = parts[1].strip()
        
        # Fundamentals: Dictionary creation (Mapping server to its usage)
        structured_data.append({
            "name": server_name,
            "usage": usage_val
        })
        
    return structured_data

def evaluate_usage(servers: List[Dict[str, str]]) -> None:
    """
    Decision logic: Demonstrates Control Flow & f-strings.
    """
    # Header using f-string alignment
    print(f"\n{'SERVER':<15} | {'STATUS':<12} | {'ACTION/MESSAGE'}")
    print("-" * 50)

    for device in servers:
        # Step-by-step: Convert string to float for comparison
        try:
            usage = float(device["usage"])
        except ValueError:
            print(f"Error: Could not process usage for {device['name']}")
            continue
            
        name = device["name"]
        
        # Control Flow: The logical ladder (Priority order matters!)
        if usage >= THRESHOLD_CRITICAL:
            status = "🚨 CRITICAL"
            msg = f"Scale UP {name} immediately! (Usage: {usage}%)"
        elif usage >= THRESHOLD_WARNING:
            status = "⚠️ WARNING"
            msg = f"Alerting SRE team. (Usage: {usage}%)"
        else:
            status = "✅ OK"
            msg = f"Resource healthy. (Usage: {usage}%)"

        # Output formatting
        print(f"{name:<15} | {status:<12} | {msg}")

# --- Execution Entry Point ---
if __name__ == "__main__":
    # Simulated input: RAW text data from a monitoring tool
    raw_input_data = """
    web-server-01 : 45.5
    db-primary    : 92.1
    cache-proxy   : 78.0
    api-gateway   : 15.2
    invalid_line_no_data
    """
    
    print("Initializing System Analysis...")
    
    # 1. Parse the data
    parsed_servers = analyze_system_logs(raw_input_data)
    
    # 2. Evaluate and Print
    evaluate_usage(parsed_servers)
    
    print("\nAnalysis Complete.")
