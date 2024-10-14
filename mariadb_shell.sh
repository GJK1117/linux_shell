#!/bin/bash

# Variables
DB_ROOT_PASSWORD="mariadb"
DB_USER="wordpress"
DB_USER_PASSWORD="wordpress"
DB_NAME="wpdb"

# Step 1: Install MariaDB
echo "Installing MariaDB server and client..."
yum install -y mariadb-server mariadb

# Step 2: Enable and Start MariaDB Service
echo "Starting and enabling MariaDB service..."
systemctl start mariadb
systemctl enable mariadb

# Step 3: Secure MariaDB Installation
echo "Securing MariaDB installation..."
mysql_secure_installation <<EOF

n
y
$DB_ROOT_PASSWORD
$DB_ROOT_PASSWORD
y
y
y
y
EOF

# Step 4: Create Database and User
echo "Setting up MariaDB database and user..."
mysql -u root -p$DB_ROOT_PASSWORD <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD';
GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Step 5: Configure MariaDB for Remote Access
echo "Configuring MariaDB for remote access..."
sed -i 's/^#bind-address.*/bind-address=0.0.0.0/' /etc/my.cnf.d/mariadb-server.cnf

# Step 6: Restart MariaDB to Apply Changes
echo "Restarting MariaDB service..."
systemctl restart mariadb

# Step 7: Configure Firewall to Allow MariaDB Remote Access
echo "Configuring firewall for MariaDB (TCP/3306)..."
firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --reload

# Step 8: Display Completion Message
echo "MariaDB installation and configuration completed!"
echo "You can now connect to the database remotely."
