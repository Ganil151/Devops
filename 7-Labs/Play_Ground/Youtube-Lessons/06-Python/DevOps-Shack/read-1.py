# Opening a file and reading its content

# Opening the file in read mode
file = open('ganil.txt', 'r')

# Opening the file in append mode
file = open('ganil.txt', 'a')

# Opening the file in write mode 
file = open('ganil.txt', 'w')

# Reading the content of the file
content = file.read()

# Writing to the file
file.write("Hello World!") 

# Closing the file
file.close()

# Printing the content read from the file
print(content)
