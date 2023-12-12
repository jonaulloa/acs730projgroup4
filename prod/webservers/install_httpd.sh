#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
myenv=`curl http://169.254.169.254/latest/meta-data/tags/instance/env`
echo "<h1>Welcome! <br> Daphne Denise Ramos! My IP is $myip.<br> My environment is $myenv. $myip"  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd