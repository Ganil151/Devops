# [x ]: 1. Read input from the user folder
# [ x]: 2. For loop, folder --> list files
# [ x]: 3. Identify modules
# [ x]: 4. Print files
# [ x]: 5. Error handling

import os
folders = input("Please provide list of folders names with spaces in between: " ).split()

for folder in folders:
    try:
      files = os.listdir(folder)
    except FileNotFoundError:
        print(f"\n ========== Please provide a valid folder name. Folder:'{folder}' does not exist. ========== ")
        continue
    except PermissionError:
        print(f"\n ========== Permission denied to access folder:'{folder}'. ========== ")
        continue 
    
    print ("\n ========== Files in folder: ", folder + " ==========")
    
    for file in files:
        print(file)
    
