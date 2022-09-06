#!/bin/bash

cd /home/ubuntu/

## Updating Packages
sudo apt update -y

## Upgrading Packages
sudo apt upgrade -y

## Installing Nginx
sudo apt install nginx -y

## Allowing Nginx Full UFW
sudo ufw allow 'Nginx Full'

## Checking UFW status
sudo ufw status

## Installing Curl and Git
sudo apt install curl git -y

## backup existing nginx configurations
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.back

## Modifying Nginx Server Configuration
sudo cat > /etc/nginx/nginx.conf <<EOL
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 1024;
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	client_max_body_size 100M;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on;

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
EOL

## Starting Nginx Services
sudo nginx -t
sudo service nginx restart
sudo service nginx status

## Writing the Script to be run as ec2-user
cat > /tmp/subscript.sh << EOF

echo "Setting up NodeJS Environment"

## Installing NVM
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

echo 'export NVM_DIR="/home/ubuntu/.nvm"' >> /home/ubuntu/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/ubuntu/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> /home/ubuntu/.bashrc

# Dot source the files to ensure that variables are available within the current shell
. /home/ubuntu/.nvm/nvm.sh
. /home/ubuntu/.profile
. /home/ubuntu/.bashrc

nvm --version

## Install Node.js
nvm install v16.17.0
nvm use v16.17.0
nvm alias default v16.17.0

## Installing Global PM2 package
npm install -g pm2

source /home/ubuntu/.bashrc

EOF

## Changing the owner of the temp script so ec2-user could run it 
chown ubuntu:ubuntu /tmp/subscript.sh && chmod a+x /tmp/subscript.sh

## Executing the script as ec2-user
sleep 1; su - ubuntu -c "/tmp/subscript.sh"