#!bin/bash

# Definition of variables
PROJECT_NAME="Phoenix-Alpha"
USER_NAME=$(whoami)


echo "System User: $USER_NAME"
echo "Initializing Project: $PROJECT_NAME"

# Taking User Input
read -p "Enter Deployment Zone [us-east-1]:" ZONE
ZONE=${ZONE:-"us-east-1"} 

echo "Deploying $ZONE..."
