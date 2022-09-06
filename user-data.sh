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