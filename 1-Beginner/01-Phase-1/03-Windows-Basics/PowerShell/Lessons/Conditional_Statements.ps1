# Conditional Statements in PowerShell
# Conditional statements allow you to execute different code based on certain conditions.
# The most common conditional statements in PowerShell are:
# - if 
# The if statement is used to execute a block of code if a specified condition is true. 
# - else
# The else statement is used to execute a block of code if the condition in the if statement is false.
# - elseif
# The elseif statement is used to specify a new condition to test if the previous condition was false.

# $age = 61

# if ($age -le 18) {
#     Write-Output "You are a minor."
# }elseif ($age -gt 18 -and $age -le 60) {
#     Write-Output "You are an adult."
# }else {
#     Write-Output "You are a senior citizen."
# }

# - switch
# The switch statement is used to execute one block of code among many based on the value of a variable or expression.
# The switch statement is more efficient than using multiple if statements when you have many conditions to check.

# Example of switch statement
$input1 = "Red"
switch ($input1) {
    "Red" { Write-Output "Stop" }
    "Yellow" { Write-Output "Caution" }
    "Green" { Write-Output "Go" }
    Default {Write-Output "Unknown color"}
}

#  Loops
# Loops are used to execute a block of code multiple times.
# The most common loops in PowerShell are:
# - for
# The for loop is used to execute a block of code a specific number of times.
# - foreach
# The foreach loop is used to iterate over a collection of items, executing a block of code for each item.  
# - while       
# The while loop is used to execute a block of code as long as a specified condition is true.
# - do while
# The do while loop is similar to the while loop, but it guarantees that the block of code will be executed at least once before checking the condition.
# - do until    
# The do until loop is similar to the do while loop, but it continues to execute the block of code until a specified condition becomes true.
# - break   
# The break statement is used to exit a loop prematurely.
# - continue
# The continue statement is used to skip the current iteration of a loop and move to the next iteration.    

# Example of for loop
for ($i = 1; $i -le 5; $i++) {
    Write-Output "Iteration $i"
}

# Example of foreach loop
$numbers = 1..5
foreach ($number in $numbers) {
    Write-Output "Number: $number"
}
# Example of while loop
$counter = 1
while ($counter -le 5) {
    Write-Output "Counter: $counter"
    $counter++
}
# Example of do while loop
$count = 0 
do {
    Write-Output $count
    $count++
    # The loop will continue until the condition is met
} while (
    $count -le 5    
)
# Example of do until loop
$count = 0
do {
    Write-Output $count
    $count++
    # The loop will continue until the condition is met
} until (
    $count -gt 5    
)
# Example of break statement
for ($i = 1; $i -le 10; $i++) {
    if ($i -eq 5) {
        break
    }
    Write-Output "Number: $i"
}
# Try/Catch/Finally
# The try/catch/finally block is used to handle exceptions in PowerShell.   
# The try block contains the code that may throw an exception, the catch block contains the code to handle the exception, and the finally block contains code that will always execute, regardless of whether an exception was thrown or not.
# Example of try/catch/finally
try {
    Get-Content -Path "C:\NonExistentFile.txt" -ErrorAction Stop
}
catch {
    Write-Output("Error:$($_.Exception.Message)")
    Get-Content -Path "C:\Users\ganil\Documents\Network-System-CE\Windows\PowerShell\Lessons\hello_chuck.txt"
}
finally {
    Write-Output("File Operation Completed")
}

