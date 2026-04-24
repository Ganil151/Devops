"""
Solution: Version Conflict Finder
"""
from collections import defaultdict

def find_conflicts(file_list):
    """Finds packages with multiple versions across files."""
    pkg_versions = defaultdict(set)
    
    for file_path in file_list:
        with open(file_path, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or '==' not in line:
                    continue
                pkg, ver = line.split('==')
                pkg_versions[pkg.lower()].add(ver)
                
    conflicts = {pkg: list(vers) for pkg, vers in pkg_versions.items() if len(vers) > 1}
    return conflicts

if __name__ == "__main__":
    print(find_conflicts(["svc1.txt", "svc2.txt"]))
