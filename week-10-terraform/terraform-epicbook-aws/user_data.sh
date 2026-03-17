#!/bin/bash

# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install nodejs npm git nginx mysql-client -y

# Enable and start nginx
sudo systemctl enable nginx
sudo systemctl start nginx
