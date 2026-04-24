"""
Lab 3: Port Range Categorizer
----------------------------
Scenario: You are auditing a firewall configuration and need to categorize
ports based on IANA standards.

Goal:
1. Practice comparison operators (>, <, >=, <=).
2. Efficiently check ranges using 'elif' chains.
"""

def categorize_port():
    print("🛡️ Firewall Port Auditor")
    user_input = input("Enter a Port Number to categorize: ").strip()

    # 1. Validation: Ensure the input is a digit
    if not user_input.isdigit():
        print(f"❌ Error: '{user_input}' is not a valid integer.")
        return

    port = int(user_input)

    # 2. Logic: Categorize using comparison logic
    if 0 <= port <= 1023:
        category = "Well-known Port (System)"
        description = "Reserved for core services like HTTP (80), SSH (22), and DNS (53)."
    
    elif 1024 <= port <= 49151:
        category = "Registered Port (User/App)"
        description = "Used for specific applications like PostgreSQL (5432) or Redis (6379)."
    
    elif 49152 <= port <= 65535:
        category = "Dynamic/Private Port (Ephemeral)"
        description = "Typically used for outbound connections and temporary port assignments."
        
    else:
        print(f"🚫 Invalid Port: {port} is outside the allowed range (0-65535).")
        return

    # 3. Output
    print(f"\n[Result] Port {port}: {category}")
    print(f"Details: {description}")

if __name__ == "__main__":
    categorize_port()
