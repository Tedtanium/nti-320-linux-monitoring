#!/bin/bash
if [ -e /var/lib/pgsql/data/pg_hba.conf ]; then exit 0; fi
#Installs python package manager, GNU compiler, and Postgres.
yum install python-pip python-devel gcc postgresql-server postgresql-devel postgresql-contrib -y

postgresql-setup initdb

systemctl start postgresql
systemctl enable postgresql

#Refer to https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-django-application-on-centos-7 for use on sed in the future.



#su - postgres
#psql


echo -e "CREATE DATABASE myproject;
\n
CREATE USER myprojectuser WITH PASSWORD 'password';
\n
ALTER ROLE myprojectuser SET client_encoding TO 'utf8';
\n
ALTER ROLE myprojectuser SET default_transaction_isolation TO 'read committed';
\n
ALTER ROLE myprojectuser SET timezone TO 'UTC';
\n
ALTER USER postgres WITH PASSWORD 'P@ssw0rd1';
GRANT ALL PRIVILEGES ON DATABASE myproject TO myprojectuser;" > sqlfile.sql

sudo -i -u postgres psql -U postgres -f /sqlfile.sql

sed -i.bak 's/ident/md5/g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's/local   all             all                                     peer/local   all             all                                     md5/g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's|host    all             all             127.0.0.1/32            md5|host    all             all             all            md5|g' /var/lib/pgsql/data/pg_hba.conf


systemctl start httpd
systemctl enable httpd
systemctl start postgresql
systemctl enable postgresql





yum install phpPgAdmin -y

sed -i 's/$conf\['\''extra_login_security'\''\] = true;/$conf\['\''extra_login_security'\''\] = false;/g' /etc/phpPgAdmin/config.inc.php
#ip/phpPgAdmin Usr: postgres PW: P@ssw0rd1
setenforce 0

sed -i 's/Require local/Require all granted/g' /etc/httpd/conf.d/phpPgAdmin.conf

sed -i 's/Allow from 127.0.0.1/Allow from all/g' /etc/httpd/conf.d/phpPgAdmin.conf

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf

sed -i 's/#port/port/g' /var/lib/pgsql/data/postgresql.conf


systemctl restart httpd
systemctl restart postgresql


#\q
#exit

#Adds repo to known repositories.
echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://10.142.0.7/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo   
