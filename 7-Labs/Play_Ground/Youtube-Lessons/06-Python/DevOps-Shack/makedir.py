# Importing the os module to work with directories
import shutil
import os

# Importing os.path module for path manipulations (not used in this snippet)
import os.path

# Importing shutil module for high-level file operations (not used in this snippet)
import shutil

# Creating a new directory named 'folder1'
os.mkdir('folder1')


# x = os.path.exists('folder1')
print('Is the exists of folder1:', x)  # Output should be True 

# Removing the directory 'folder1' after verification
os.rmdir('folder1')  

# Cleaning up by removing the created file
os.remove('ganil.txt')

# Shutil module to remove a directory and all its contents
shutil.rmtree('folder1')

# Listing all items in the current directory to verify creation
a = os.listdir('.') 
print(a)  # Output should include 'folder1' among other items
