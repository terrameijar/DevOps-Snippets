#!/bin/bash

# Download updates
yum update -y

# Install Apache Web Server
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Install PHP and required modules
yum install -y php php-mysqlnd php-gd php-fpm php-mysqli php-json php-devel

# Download and extract WordPress
cd /var/www/html
curl -O https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz


# Set Permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Create the WordPress Config file
cp wp-config-sample.php wp-config.php
sed -i 's/database_name_here/wordpress/' wp-config.php
sed -i 's/username_here/wordpress-admin/' wp-config.php
sed -i 's/password_here/$%jP8@qR3zLx/' wp-config.php

DATABASE_HOST="10.255.181.11" # Private IP or Hostname
sed -i "s/define('DB_HOST', 'localhost');/define('DB_HOST', '$DATABASE_HOST');/" wp-config.php

# Restart Apache
systemctl restart httpd