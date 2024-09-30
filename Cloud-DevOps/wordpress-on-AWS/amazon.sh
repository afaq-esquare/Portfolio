#!/bin/bash

# Update system packages
sudo yum update -y

# Install dependncies
sudo amazon-linux-extras enable php7.2
sudo yum install -y php php-mysqlnd
sudo yum install -y php-gd php-xml php-mbstring

# Install and configure Apache web server
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Download  WordPress
sudo yum install -y wget
wget https://wordpress.org/latest.tar.gz

#extract
tar -xzf latest.tar.gz
sudo mv wordpress/* /var/www/html/

#renaming wp-config-sample to use as wp-config.php
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Configure permissions for WordPress
sudo chown -R apache:apache /var/www/html/
sudo chmod -R 700 /var/www/html/

# Update Apache configuration
echo "<Directory /var/www/html/>
    AllowOverride All
</Directory>" | sudo tee -a /etc/httpd/conf.d/wordpress.conf

# Set database details in WordPress configuration
sudo sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', \'${DB_NAME}\' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', \'${DB_USER}\' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', \'${DB_PASSWORD}\' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', \'${DB_HOST}\' );/" /var/www/html/wp-config.php
# Set this to avoid breaking css after SSL certificate
sudo sed -i 's/<?php/<?php\n if (isset($_SERVER['\''HTTP_X_FORWARDED_PROTO'\'']) \&\& $_SERVER['\''HTTP_X_FORWARDED_PROTO'\''] === '\''https'\''\){ $_SERVER['\''HTTPS'\''] = '\''on'\''; }/' /var/www/html/wp-config.php

# Restart Apache
sudo systemctl restart httpd

# Clean up temporary files
rm -rf latest.tar.gz wordpress
