#!/bin/bash

# Variables
DATABASE_NAME="wordpress"
DATABASE_USER="wordpress-admin"
DATABASE_PASSWORD="$%jP8@qR3zLx"

yum update -y || { echo "Failed to update packages"; exit 1; }
yum install mariadb105-server -y || { echo "Failed to install MariaDB server"; exit 1; }

# Start and enable mysql
systemctl start mariadb || { echo "Failed to start MariaDB"; exit 1; }
systemctl enable mariadb || { echo "Failed to enable MariaDB"; exit 1; }

# Create a MySQL DB, user, and grant privileges
mysql -u root -e "CREATE DATABASE '${DATABASE_NAME};" || { echo "Failed to create database"; exit 1; }
mysql -u root -e "CREATE USER '${DATABASE_USER}'@'%' IDENTIFIED BY '${DATABASE_PASSWORD}';" || { echo "Failed to create user"; exit 1; }
mysql -u root -e "GRANT ALL PRIVILEGES ON '${DATABASE_NAME}'.* TO '${DATABASE_USER}'@'%';" || { echo "Failed to grant privileges"; exit 1; }
mysql -u root -e "FLUSH PRIVILEGES;"

# Allow external connections
sed -i '/^#bind-address/s/^#//' /etc/my.cnf.d/mariadb-server.cnf

# Restart Mariadb and apply changes
systemctl restart mysqld
