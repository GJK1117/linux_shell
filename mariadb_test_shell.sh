#!/bin/bash

# Variables
MARIADB_SERVER_IP="192.168.137.103"
DB_USER="wordpress"
DB_USER_PASSWORD="wordpress"

# Step 1: Install MariaDB Client
echo "Installing MariaDB client..."
yum install -y mariadb

# Step 2: Test Remote Connection to MariaDB Server
echo "Testing remote connection to MariaDB server at $MARIADB_SERVER_IP..."
mysql -h $MARIADB_SERVER_IP -u $DB_USER -p$DB_USER_PASSWORD -e "SHOW DATABASES;"

# Step 3: Display Completion Message
echo "Remote MariaDB connection test completed!"
