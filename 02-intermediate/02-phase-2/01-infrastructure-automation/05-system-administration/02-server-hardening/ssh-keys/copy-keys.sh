\#\!/bin/bash

\# Define vars  
PEM\_FILE="DevOps-Shack.pem"  
PUB\_KEY=$(cat \~/.ssh/id\_rsa.pub)  
USER="ubuntu"  \# or ec2-user  
INVENTORY\_FILE="inventory/aws\_ec2.yaml"

\# Extract hostnames/IPs from dynamic inventory  
HOSTS=$(ansible-inventory \-i $INVENTORY\_FILE \--list | jq \-r '.\_meta.hostvars | keys\[\]')

for HOST in $HOSTS; do  
  echo "Injecting key into $HOST"  
  ssh \-o StrictHostKeyChecking=no \-i $PEM\_FILE $USER@$HOST "  
    mkdir \-p \~/.ssh && \\  
    echo \\"$PUB\_KEY\\" \>\> \~/.ssh/authorized\_keys && \\  
    chmod 700 \~/.ssh && \\  
    chmod 600 \~/.ssh/authorized\_keys  
  "  
done
