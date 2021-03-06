#!/bin/bash

if [ -e opt/myproject/myproject/settings.py ]; then exit 0; fi

yum install python-pip wget telnet -y
pip install virtualenv
pip install --upgrade pip
pip install django psycopg2

#Adds repo to known repositories.
echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://10.142.0.7/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo   

mkdir /opt/myproject
virtualenv /opt/myproject/myprojectenv
source /opt/myproject/myprojectenv/bin/activate
django-admin.py startproject myproject /opt/myproject

#vim myproject/settings.py
#Look into notes to find what to edit via sed (probably IP address info grepped with Gcloud API).


mv /opt/myproject/myproject/settings.py /opt/myproject/myproject/settings.py.bak


source /opt/myproject/myprojectenv/bin/activate && pip install django psycopg2 && django-admin.py startproject myproject /opt/myproject/
mv /opt/myproject/myproject/settings.py /settings.py.bak

wget https://raw.githubusercontent.com/Tedtanium/nti-310-linux-enterprise-applications/master/django-thing/settings.py --directory-prefix=/opt/myproject/myproject/

postgresip=$(getent hosts postgres.c.nti-310-200201.internal | awk '{ print $1 }')

sed -i "s|'HOST': '1.2.3.4'|'HOST': 'POSTGRESIP'|g" /opt/myproject/myproject/settings.py
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS =  \[\'"*"\'\]/g" /opt/myproject/myproject/settings.py


echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'pass')" | /opt/myproject/manage.py shell

source /opt/myproject/myprojectenv/bin/activate && python /opt/myproject/manage.py makemigrations && python /opt/myproject/manage.py migrate && python /opt/myproject/manage.py runserver 0.0.0.0:8000


