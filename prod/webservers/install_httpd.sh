#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1><center>GROUP 4 ACS730 FINAL PROJECT<br>Members:<br> Daphne Denise Ramos <br>
Jonalyn Ulloa <br>
Rose Ann Camantes <br>
Michael Concepcion <br>
Augustine Opoku Junior Antwi <br>
My IP is $myip."  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd
