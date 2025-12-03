import paramiko

def configure_switch(switch_ip, username, password, commands):
    try:
        # Create an SSH client
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # Connect to the switch
        ssh_client.connect(hostname=switch_ip, username=username, password=password)
        
        # Start an interactive shell session
        shell = ssh_client.invoke_shell()
        
        # Send configuration commands
        for command in commands:
            shell.send(command + '\n')
            # Allow time for the command to be processed
            time.sleep(1)
        
        # Close the connection
        ssh_client.close()
        print(f"Configuration for {switch_ip} completed.")
        
    except Exception as e:
        print(f"Failed to configure {switch_ip}: {str(e)}")

# Configuration commands for each switch
wl_sw_commands = [
    "configure terminal",
    "vlan 2",
    "name Finishline-AP",
    "exit",
    "vlan 3",
    "name Guest-AP",
    "exit",
    "do write",
    "spanning-tree mode rapid-pvst"
]

data_sw_commands = [
    "configure terminal",
    "vlan 10",
    "name MGMT-IPH",
    "exit",
    "vlan 20",
    "name MGMT-PC",
    "exit",
    "vlan 30",
    "name REP-IPH",
    "exit",
    "vlan 40",
    "name REP-PC",
    "exit",
    "vlan 50",
    "name Office-A-IPH",
    "exit",
    "vlan 60",
    "name Office-A-PC",
    "exit",
    "vlan 65",
    "name Office-A-LP",
    "exit",
    "vlan 70",
    "name Office-A-PR",
    "exit",
    "do write",
    "spanning-tree mode rapid-pvst"
]

dmz_sw_commands = [
    "configure terminal",
    "vlan 96",
    "name EMAIL-SR",
    "exit",
    "vlan 97",
    "name FTP-SR",
    "exit",
    "vlan 98",
    "name DNS-SR",
    "exit",
    "vlan 99",
    "name WEB-SR",
    "exit",
    "do write",
    "spanning-tree mode rapid-pvst"
]

# Switch IP addresses
switches = {
    "WL-SW": {"ip": "192.168.1.1", "commands": wl_sw_commands},
    "DATA-SW": {"ip": "192.168.2.1", "commands": data_sw_commands},
    "DMZ-SW": {"ip": "192.168.3.1", "commands": dmz_sw_commands}
}

# Credentials
username = "admin"
password = "password"

# Configure each switch
for switch_name, switch_info in switches.items():
    print(f"Configuring {switch_name} ({switch_info['ip']})...")
    configure_switch(switch_info['ip'], username, password, switch_info['commands'])
