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

  
vim /etc/cacti/db.php            # Set database username and password in $database_username = ''; and $database_password = '';


vim /etc/httpd/conf.d/cacti.conf     # Top open up access from your subnet, external host or anywere.  Note, anywere isn't recommended
                              

systemctl restart httpd.service
sed -i 's/#//g' /etc/cron.d/cacti
setenforce 0




End scripty part.  Further bug fixes, you'll need to update your php.ini like so:
[root@cacti-c etc]# diff php.ini php.ini.orig 
878c878
< date.timezone = America/Regina
---
> ;date.timezone =
