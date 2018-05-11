#!/bin/bash
if [ -e /etc/nagios/objects/commands.cfg ]; then exit 0; fi
yum install nagios -y
systemctl enable nagios
systemctl start nagios
yum install -y httpd
setenforce 0
yum install -y nrpe
systemctl enable nrpe
systemctl start nrpe
yum install nagios-plugins-all -y
yum -y install nagios-plugins-nrpe

yum install -y nagios-selinux -y
systemctl restart nagios
setenforce 1

echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://10.142.0.7/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo 

echo '########### NRPE CONFIG LINE #######################
define command{
command_name check_nrpe
command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}' >> /etc/nagios/objects/commands.cfg
