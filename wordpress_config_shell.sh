#!/bin/bash

# Variables
WORDPRESS_DOWNLOAD_URL="https://ko.wordpress.org/latest-ko_KR.tar.gz"
WORDPRESS_DIR="/var/www/html/wordpress"
APACHE_CONFIG="/etc/httpd/conf.d/wordpress.conf"
SERVER_IP="192.168.137.102"
SERVER_ADMIN_EMAIL="wordpress@localhost"

# Step 1: Install necessary packages
echo "Installing required packages..."
yum install -y wget tar httpd

# Step 2: Download WordPress
echo "Downloading WordPress..."
wget $WORDPRESS_DOWNLOAD_URL -O /tmp/latest-ko_KR.tar.gz

# Step 3: Extract WordPress
echo "Extracting WordPress..."
tar xzvf /tmp/latest-ko_KR.tar.gz -C /tmp

# Step 4: Copy WordPress to Apache directory
echo "Copying WordPress to $WORDPRESS_DIR..."
cp -R /tmp/wordpress $WORDPRESS_DIR

# Step 5: Set permissions for WordPress directory
echo "Setting ownership and permissions for $WORDPRESS_DIR..."
chown -R apache:apache $WORDPRESS_DIR
chmod -R 775 $WORDPRESS_DIR

# Step 6: Configure Apache virtual host for WordPress
echo "Configuring Apache virtual host for WordPress..."
cat <<EOF > $APACHE_CONFIG
<VirtualHost $SERVER_IP:80>
    ServerName $SERVER_IP
    ServerAdmin $SERVER_ADMIN_EMAIL
    DocumentRoot $WORDPRESS_DIR

    <Directory "$WORDPRESS_DIR">
        Options Indexes FollowSymLinks
        AllowOverride all
        Require all granted
    </Directory>

    ErrorLog /etc/httpd/logs/wordpress_error.log
    CustomLog /etc/httpd/logs/wordpress_access.log common
</VirtualHost>
EOF

# Step 7: Restart Apache service
echo "Restarting Apache service..."
systemctl restart httpd

# Step 8: Display completion message
echo "WordPress installation and configuration completed!"
echo "You can now complete the WordPress setup by visiting http://$SERVER_IP in your browser."
