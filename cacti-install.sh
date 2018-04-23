#!/bin/bash
yum -y install cacti              
yum install mariadb-server
                                   
yum install php-process php-gd php mod_php
                                   
                    
systemctl enable mariadb         
systemctl enable httpd
systemctl enable snmpd


systemctl start mariadb        
systemctl start httpd
systemctl start snmpd

mysqladmin -u root password badpassword


mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p mysql 

echo "create database cacti;
GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'badpassword'; 
FLUSH privileges;
GRANT SELECT ON mysql.time_zone_name TO cacti@localhost;       
flush privileges;" > stuff.sql


mysql -u root  -p < stuff.sql   
rpm -ql cacti|grep cacti.sql     

mysql cacti < /usr/share/doc/cacti-1.1.37/cacti.sql -u cacti -p  

  
#vim /etc/cacti/db.php
sed -i 's/cactiuser/tjensen/g' /etc/cacti/db.php
sed -i '/cactipass/badpassword/g' /etc/cacti/db.php

#vim /etc/httpd/conf.d/cacti.conf  
sed -i 's/Allow from localhost/Require all granted/g' /etc/httpd/conf.d/cacti.conf


sed -i 's/#//g' /etc/cron.d/cacti
setenforce 0

sed -i 's`; http://php.net/date.timezone`http://php.net/date.timezone`g' /etc/php.ini
sed -i 's`;date.timezone =`date.timezone = America/Regina`g' /etc/conf.d /etc/php.ini

systemctl restart httpd.service
systemctl restart cacti
