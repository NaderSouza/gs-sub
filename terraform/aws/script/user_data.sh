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
mkdir /var/www/html

cp /tmp/gs-sub/app/index.html /var/www/html

# Alteração aqui para selecionar o arquivo certo com base no nome da instância
# if [[ "$(hostname)" == "web-1" || "$(hostname)" == "web-2" ]]; then
#   cp /tmp/gs-sub/app/index.html /var/www/html
# else
#   cp /tmp/gs-sub/app/index2.html /var/www/html
# fi


echo "Start Apache service"
service httpd restart

