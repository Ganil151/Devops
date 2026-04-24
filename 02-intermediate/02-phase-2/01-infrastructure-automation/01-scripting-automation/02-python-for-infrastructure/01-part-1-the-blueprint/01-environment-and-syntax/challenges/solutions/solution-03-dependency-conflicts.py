"""
Solution: Dependency Conflict Resolver
"""

def parse_requirements(file_path):
    pkg_map = {}
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if '==' in line:
                name, ver = line.split('==')
                pkg_map[name.lower()] = ver
    return pkg_map

def find_conflicts(req1_path, req2_path):
    map1 = parse_requirements(req1_path)
    map2 = parse_requirements(req2_path)
    
    conflicts = {}
    # Find shared keys
    shared_pkgs = set(map1.keys()) & set(map2.keys())
    
    for pkg in shared_pkgs:
        if map1[pkg] != map2[pkg]:
            conflicts[pkg] = [map1[pkg], map2[pkg]]
            
    return conflicts

if __name__ == "__main__":
    print(find_conflicts("team_a.txt", "team_b.txt"))
