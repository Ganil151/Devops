"""
Challenge: Dependency Conflict Resolver
Scenario: You are merging two teams' workloads. 
Both have 'requirements.txt' files. You need to identify shared packages 
that have different version pins.

TODO: Implement `find_conflicts(req1_path, req2_path)`.
1. Parse each file into a dictionary: `{"package_name": "version"}`.
2. Find the intersection (packages present in both).
3. If the version differs for a shared package, add it to a `conflicts` dict.
4. Return the `conflicts` dict.
"""

def parse_requirements(file_path):
    # Helper to parse "pkg==ver" lines
    pass

def find_conflicts(req1_path, req2_path):
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Create test files
    with open("team_a.txt", "w") as f:
        f.write("requests==2.31.0\nboto3==1.28.0\npyyaml==6.0")
    with open("team_b.txt", "w") as f:
        f.write("requests==2.28.0\nboto3==1.28.0\npandas==2.0.0")
        
    conflicts = find_conflicts("team_a.txt", "team_b.txt")
    print(f"Conflicts found: {conflicts}")
    # Expected: {'requests': ['2.31.0', '2.28.0']}
