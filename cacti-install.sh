#!/bin/bash

yum -y install cacti              
yum install mariadb-server -y
                                   
yum install php-process php-gd php mod_php -y
                                   
                    
systemctl enable mariadb         
systemctl enable httpd
systemctl enable snmpd


systemctl start mariadb        
systemctl start httpd
systemctl start snmpd

chmod 775 /usr/share/cacti/resource/s*

mysqladmin -u root password badpassword


mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -pbadpassword mysql 

echo -e "create database cacti;
\n
GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'badpassword'; 
\n
FLUSH privileges;
\n
GRANT SELECT ON mysql.time_zone_name TO cacti@localhost;  
\n
flush privileges;" > stuff.sql
    
mysql -u root  -pbadpassword < stuff.sql

mysql cacti < /usr/share/doc/cacti-1.1.37/cacti.sql -u root -pbadpassword



  
#vim /etc/cacti/db.php
sed -i 's/username = '\''cactiuser'\''/username = '\''cacti'\''/g' /etc/cacti/db.php
sed -i 's/password = '\''cactiuser'\''/password = '\''badpassword'\''/g' /etc/cacti/db.php

#vim /etc/httpd/conf.d/cacti.conf  
sed -i 's/Require host localhost/Require all granted/g' /etc/httpd/conf.d/cacti.conf
sed -i 's/Require all granted/Allow from all/g' /etc/httpd/conf.d/cacti.conf


sed -i 's/#//g' /etc/cron.d/cacti

sed -i 's`;date.timezone =`date.timezone = America/Regina`g' /etc/php.ini

systemctl restart httpd.service

setenforce 0

#After install: If things aren't writable, use [chmod 775 /usr/share/cacti/resource/s*] and set SELinux to permissive, with 
[vim /etc/selinux/config] or [setenforce 0].
