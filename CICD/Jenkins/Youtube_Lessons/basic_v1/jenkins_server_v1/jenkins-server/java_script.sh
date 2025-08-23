#!/bin/bash

# Update package lists
sudo apt update -y

# Install Java Runtime Environment 
sudo apt install -y fontconfig openjdk-21-jre
java -version