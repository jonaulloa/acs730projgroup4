 #!/bin/bash
 yum -y update
 yum -y install httpd
 myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
 echo "Welcome, Daphne Denise Ramos! My IP is $myip. Current environment is ${env}."  >  /var/www/html/index.html
 sudo systemctl start httpd
 sudo systemctl enable httpd