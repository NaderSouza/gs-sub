#!/bin/bash
    
echo "Update with latest packages"
yum update -y
    
echo "Install Apache"
yum install -y httpd git
    
echo "Enable Apache service to start after reboot"
sudo systemctl enable httpd
    
echo "Install application"
cd /tmp
git clone https://github.com/NaderSouza/gs-sub
mkdir /var/www/html2
cp /tmp/gs-sub/app/*.html /var/www/html2

echo "Start Apache service"
service httpd restart
