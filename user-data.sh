#!/bin/bash

sudo apt update -y

sudo apt upgrade -y

sudo apt install nginx -y

sudo ufw allow 'Nginx Full'

sudo ufw status

sudo apt install curl -y
