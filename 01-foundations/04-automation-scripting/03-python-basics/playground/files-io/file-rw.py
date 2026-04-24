# [ x] Read the contents of a file named "server.config" 
# [ x] List all variables defined in the file (lines that contain '=')
# [ x] Write mode 
# [ ] Update the value of a variable named "max_connections" to "200"
# [ ] Save the changes back to the file

def update_server_config(file_path, key, value):
    
    with open(file_path, 'r') as file:
        lines = file.readlines()
        
    with open(file_path, 'w') as file:
        for line in lines:
            if key in line:
                file.write(key + '=' + value + '\n')
            else:
                file.write(line)

update_server_config("server.conf", "MAX_CONNECTIONS", "1000")