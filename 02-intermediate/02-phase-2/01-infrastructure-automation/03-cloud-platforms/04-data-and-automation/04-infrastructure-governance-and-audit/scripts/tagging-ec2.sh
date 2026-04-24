\#\!/bin/bash

\# Fetch instance IDs that match Environment=dev and Role=web  
instance\_ids=$(aws ec2 describe-instances \\  
  \--filters "Name=tag:Environment,Values=dev" "Name=instance-state-name,Values=running" \\  
  \--query 'Reservations\[\*\].Instances\[\*\].InstanceId' \\  
  \--output text)

\# Sort instance IDs deterministically  
sorted\_ids=($(echo "$instance\_ids" | tr '\\t' '\\n' | sort))

\# Rename instances sequentially  
counter=1  
for id in "${sorted\_ids\[@\]}"; do  
  name="web-$(printf "%02d" $counter)"  
  echo "Tagging $id as $name"  
  aws ec2 create-tags \--resources "$id" \\  
    \--tags Key=Name,Value="$name"  
  ((counter++))  
done