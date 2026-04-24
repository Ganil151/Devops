"""
Challenge: Version Conflict Finder
Scenario: You have multiple microservices, each with its own 
`requirements.txt`. You want to check if any service is using a 
different version of a shared package (e.g., `requests`).

TODO: Implement `find_conflicts(file_list)`.
1. Parse each file in `file_list`.
2. Map package names to a set of versions found across files.
3. If a package has more than one unique version specifier, mark it as a conflict.
4. Return a dictionary of conflicts: `{"pkg": ["ver1", "ver2"]}`.
"""

def find_conflicts(file_list):
    """
    Identifies conflicting package versions across multiple files.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    with open("svc1.txt", "w") as f: f.write("requests==2.31.0\n")
    with open("svc2.txt", "w") as f: f.write("requests==2.28.0\nboto3==1.26.0")
    
    conflicts = find_conflicts(["svc1.txt", "svc2.txt"])
    print(f"Conflicts: {conflicts}")
