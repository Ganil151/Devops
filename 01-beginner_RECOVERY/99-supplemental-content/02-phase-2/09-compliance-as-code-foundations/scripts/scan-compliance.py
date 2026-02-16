"""
Compliance Scanner
Description: Checks system state against a JSON policy.
"""

import os
import json
import pwd

POLICY = {
    "files": [
        {"path": "/etc/passwd", "max_perm": 644},
        {"path": "/etc/shadow", "max_perm": 600}
    ],
    "users": ["root", "nobody"]
}

def check_file(rule):
    path = rule['path']
    if not os.path.exists(path):
        print(f"[WARN] {path} not found.")
        return
        
    stat = os.stat(path)
    mode = int(oct(stat.st_mode)[-3:])
    
    if mode > rule['max_perm']:
        print(f"[FAIL] {path} is {mode} (Max permitted: {rule['max_perm']})")
    else:
        print(f"[PASS] {path} is {mode}")

def check_user(username):
    try:
        pwd.getpwnam(username)
        print(f"[PASS] User '{username}' exists.")
    except KeyError:
        print(f"[WARN] User '{username}' missing (might be required).")

def main():
    print("Compliance Scan Running...")
    
    print("\nFile Permissions:")
    for rule in POLICY['files']:
        check_file(rule)
        
    print("\nRequired Users:")
    for user in POLICY['users']:
        check_user(user)

if __name__ == "__main__":
    main()
