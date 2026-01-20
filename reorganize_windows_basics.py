import os
import shutil

base_path = r"C:\Users\Ganil\Documents\Devops\1-Beginner\01-Phase-1\03-Windows-Basics"

mapping = {
    "PowerShell": "Part-1-PowerShell-Automation",
    "WSL": "Part-2-WSL-Linux-Integration",
    "WinGet": "Part-3-Package-Management",
    "Server2022": "Part-4-Server-Administration",
    "Container": "Part-5-Windows-Containers",
    "Auditing": "Part-6-System-Auditing",
    "Proformance": "Part-7-Performance-Tuning",
    "Hacks&Tricks": "Part-8-Pro-Tips"
}

print(f"Starting reorganization in {base_path}...")

if not os.path.exists(base_path):
    print(f"Error: {base_path} does not exist.")
    exit(1)

# List current directories
for item in os.listdir(base_path):
    src = os.path.join(base_path, item)
    if os.path.isdir(src):
        if item in mapping:
            dst_name = mapping[item]
            dst = os.path.join(base_path, dst_name)
            try:
                print(f"Renaming '{item}' to '{dst_name}'...")
                os.rename(src, dst)
            except Exception as e:
                print(f"Error renaming {item}: {e}")
        else:
            print(f"Skipping '{item}' (Not in mapping)")

# Create a README for the Module if it doesn't exist or update it
readme_path = os.path.join(base_path, "README.md")
readme_content = """# Windows Basics Module

This module covers the essential skills for managing and automating Windows environments in a DevOps context.

## Curriculum

- **Part 1: PowerShell Automation** (Formerly PowerShell) - The core of Windows automation.
- **Part 2: WSL Integration** (Formerly WSL) - Running Linux on Windows.
- **Part 3: Package Management** (Formerly WinGet) - Modern software management.
- **Part 4: Server Administration** (Formerly Server2022) - Windows Server specifics.
- **Part 5: Windows Containers** (Formerly Container) - Docker on Windows.
- **Part 6: System Auditing** (Formerly Auditing) - Discovery and reporting.
- **Part 7: Performance Tuning** (Formerly Proformance) - Optimization techniques.
- **Part 8: Hacks & Tips** (Formerly Hacks&Tricks) - Productivity boosters.

## Resources
- [Official Microsoft Docs](https://docs.microsoft.com/en-us/windows/)
"""

with open(readme_path, "w") as f:
    f.write(readme_content)

print("Reorganization complete.")
