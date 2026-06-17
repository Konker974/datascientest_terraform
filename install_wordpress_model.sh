#!/bin/bash

# variables
DB_NAME="wordpress_db"            # Name of the database
DB_USER="datascientest-student"       # Database username
DB_PASSWORD="Datascientest@2024"      # Database password

WORDPRESS_DIR="/var/www/html"     # wordpress code directory

# Update the system
sudo yum update -y

# Install expect package
sudo yum install expect -y

# Install Apache HTTP server
sudo yum install -y httpd wget php-fpm php-mysqli php-json php php-devel
sudo yum install -y mariadb105-server
# Start Apache &  Enable Apache to start on boot
sudo systemctl start httpd && sudo systemctl enable httpd
sudo usermod -a -G apache ec2-user
# Create a PHP info page
sudo chown -R ec2-user:apache /var/www/html/
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php


# Install required PHP modules
sudo yum install php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap} -y


# Start MariaDB & Enable MariaDB to start on boot

sudo systemctl enable --now mariadb

# Install
sudo yum install expect -y

# Secure the MariaDB installation
echo "Securing MariaDB installation..."
expect - <<EOF
spawn sudo mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "\r"
expect "Switch to unix_socket authentication:"
send "n\r"
expect "Change the root password?"
send "y\r"
expect "New password:"
send "$DB_PASSWORD\r"
expect "Re-enter new password:"
send "$DB_PASSWORD\r"
expect "Remove anonymous users?"
send "y\r"
expect "Disallow root login remotely?"
send "y\r"
expect "Remove test database and access to it?"
send "y\r"
expect "Reload privilege tables now?"
send "y\r"
expect eof
EOF
echo "MariaDB installation secured."

# Change to the user's home directory
cd /home/ec2-user

# Download the latest WordPress
wget https://wordpress.org/latest.zip

# Unzip the WordPress archive
unzip latest.zip

# Move WordPress files to Apache's web directory
mv wordpress/* ${WORDPRESS_DIR}

# Change ownership of the web directory
sudo chown -R ec2-user:apache ${WORDPRESS_DIR}

sudo -i
# Create the WordPress database
mysql -u root  -e "CREATE DATABASE $DB_NAME;"

# Create a user for the database
mysql -u root  -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"

# Grant privileges to the user
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"

# Flush privileges
mysql -u root -e "FLUSH PRIVILEGES;"

exit

cd

# Change to the WordPress directory
cd ${WORDPRESS_DIR}

# Create a WordPress configuration file from the sample
cp wp-config-sample.php wp-config.php

# Replace database name in the configuration file
sed -i "s/database_name_here/$DB_NAME/" wp-config.php

# Replace database username in the configuration file
sed -i "s/username_here/$DB_USER/" wp-config.php

# Replace database password in the configuration file
sed -i "s/password_here/$DB_PASSWORD/" wp-config.php

# Replace database host in the configuration file
sed -i "s/localhost/localhost/" wp-config.php


# Set appropriate permissions for the web directory (directories)
sudo find ${WORDPRESS_DIR} -type d -exec chmod 755 {} \;

# Set appropriate permissions for the web directory (files)
sudo find ${WORDPRESS_DIR} -type f -exec chmod 644 {} \;

# Restart Apache
sudo systemctl restart httpd

echo
echo "**************************************************************************************"
echo "******** Datascientest Wordpress installation  has been executed successfully ********"
echo "**************************************************************************************"
echo