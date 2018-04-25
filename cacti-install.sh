#!/bin/bash

yum -y install cacti              
yum install mariadb-server
                                   
yum install php-process php-gd php mod_php -y
                                   
                    
systemctl enable mariadb         
systemctl enable httpd
systemctl enable snmpd


systemctl start mariadb        
systemctl start httpd
systemctl start snmpd

mysqladmin -u root password 
badpassword
badpassword

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p mysql 

echo "create database cacti;

GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'badpassword'; 

FLUSH privileges;

GRANT SELECT ON mysql.time_zone_name TO cacti@localhost;  

flush privileges;" > stuff.sql


mysql -u root  -p < stuff.sql   
rpm -ql cacti|grep cacti.sql     

mysql cacti < /usr/share/doc/cacti-1.1.37/cacti.sql -u cacti -p  
mysql -u root  -p < stuff.sql

  
#vim /etc/cacti/db.php
sed -i 's/username = '\''cactiuser'\''/username = '\''tjensen'\''/g' /etc/cacti/db.php
sed -i 's/password = '\''cactiuser'\''/password = '\''badpassword'\''/g' /etc/cacti/db.php

#vim /etc/httpd/conf.d/cacti.conf  
sed -i 's/Allow from localhost/Require all granted/g' /etc/httpd/conf.d/cacti.conf


sed -i 's/#//g' /etc/cron.d/cacti

sed -i 's`;date.timezone =`date.timezone = America/Regina`g' /etc/conf.d /etc/php.ini

systemctl restart httpd.service

setenforce 0
