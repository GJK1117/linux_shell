#!/bin/bash

# Variables
SERVER_IP="192.168.137.102"
FIREWALL_HTTP_SERVICE="http"

# Step 1: Install Apache Web Server
echo "Installing Apache Web Server..."
yum install -y httpd

# Step 2: Enable and Start Apache
echo "Enabling and starting Apache..."
systemctl enable httpd
systemctl start httpd

# Step 3: Configure Firewall for HTTP Service
echo "Configuring firewall for HTTP service..."
firewall-cmd --add-service=$FIREWALL_HTTP_SERVICE --permanent
firewall-cmd --reload

# Step 4: Test Apache Installation
echo "Creating a test HTML file..."
echo "Hello Cloud" > /var/www/html/index.html

# Step 5: Install PHP
echo "Enabling PHP 8.1 module..."
yum module enable php:8.1 -y

echo "Installing PHP and additional PHP modules..."
yum install -y php php-* wget

# Step 6: Configure Apache for PHP
echo "Configuring Apache to work with PHP..."
sed -i 's/#ServerName www.example.com:80/ServerName '$SERVER_IP':80/' /etc/httpd/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/httpd/conf/httpd.conf
echo "AddType application/x-httpd-php .php" >> /etc/httpd/conf/httpd.conf
echo "AddType application/x-httpd-phps .phps" >> /etc/httpd/conf/httpd.conf

# Step 7: Configure PHP-FPM
echo "Configuring PHP-FPM..."
sed -i 's/;listen.acl_groups = apache/listen.acl_groups = apache/' /etc/php-fpm.d/www.conf

# Step 8: Restart Apache and PHP-FPM services
echo "Restarting Apache and PHP-FPM services..."
systemctl restart httpd
systemctl start php-fpm
systemctl enable php-fpm

# Step 9: Create a PHP info page for testing
echo "Creating phpinfo.php for testing..."
cat <<EOF > /var/www/html/phpinfo.php
<?php
phpinfo();
?>
EOF

# Step 10: Display completion message
echo "Apache and PHP installation and configuration completed!"
echo "Test by accessing: http://$SERVER_IP/phpinfo.php"
