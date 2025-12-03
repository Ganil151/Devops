# PowerShell Pipeline
# The PowerShell pipeline is a powerful feature that allows you to pass the output of one command as input to another command. This enables you to chain together multiple commands to perform complex tasks in a more efficient and readable way.
# A pipeline is a series of commands connected by the pipe operator (|).
# The output of the command on the left side of the pipe operator is passed as input to the command on the right side.
# The pipeline allows you to process data in a step-by-step manner, transforming or filtering it as needed.
# Command1 | Command2 | Command3

# "Hello World" | ForEach-Object { $_.ToUpper()}
# The above command takes the string "Hello World", converts it to uppercase using ForEach-Object, and outputs "HELLO WORLD".

# Example 1: Using the pipeline to filter and sort processes
# Get-Process | Where-Object { $_.Name -eq "Notepad" } | Select-Object id, Name 

# Get-Service | Where-Object { $_.Status -eq "Running"}  
# The above command retrieves all running services and filters them to show only those with the status "Running".

# Get-ChildItem -Path "C:\Users\ganil\Documents\Network-System-CE"
# The above command retrieves all files and directories in the specified path.
Get-ChildItem -Path "C:\Users\ganil\Documents\Network-System-CE" | Where-Object { $_.Length -gt 32MB } | Sort-Object Length -Descending | Select-Object Name, Length
# The above command retrieves all files in the specified path, filters them to show only those larger than 1MB, sorts them by size in descending order, and selects the Name and Length properties for display.