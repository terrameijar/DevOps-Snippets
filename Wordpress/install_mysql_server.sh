#!/bin/bash

yum update -y
yum install mariadb105-server -y

# Start and enable mysql
systemctl start mariadb
systemctl enable mariadb
# Get initial password
# sudo grep 'temporary password' /var/log/mysqld.log

# sudo mysql_secure_installation -p


mysql -u root -e "CREATE DATABASE wordpress;"

# Create a MySQL user and grant privileges
mysql -u root -e "CREATE USER 'wordpress-admin'@'%' IDENTIFIED BY '$%jP8@qR3zLx';"
mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress-admin'@'%';"
mysql -u root -e "FLUSH PRIVILEGES;"

Allow external connections
sed -i '/^#bind-address/s/^#//' /etc/my.cnf.d/mariadb-server.cnf

Restart and apply changes
systemctl restart mysqld
# https://awstip.com/deploying-a-three-tier-architecture-web-solution-with-wordpress-on-aws-bc04497269a2