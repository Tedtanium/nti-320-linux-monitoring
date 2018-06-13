#!/bin/bash
if [ -e /etc/nagios/objects/commands.cfg ]; then exit 0; fi

yum install nagios nrpe nagios-plugins-all nagios-plugins-nrpe nagios-selinux httpd wget -y

wget https://raw.githubusercontent.com/Tedtanium/nti-320-linux-monitoring/master/automated-network/configs/generate-nagios-client.sh

systemctl enable nagios
systemctl start nagios
systemctl enable nrpe
systemctl start nrpe
systemctl enable httpd
systemctl start httpd


echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://REPOSERVERIP/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo 

echo '########### NRPE CONFIG LINE #######################
define command{
command_name check_nrpe
command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}' >> /etc/nagios/objects/commands.cfg

echo "*.info;mail.none;authpriv.none;cron.none   @RSYSLOGIP" >> /etc/rsyslog.conf && systemctl restart rsyslog.service

#Disables authentication.
sed -i 's/use_authentication=1/use_authentication=0/g' /etc/nagios/cgi.cfg
sed -i 's/AuthName/#Authname/g' /etc/httpd/conf.d/nagios.conf
sed -i 's/AuthType/#AuthType/g' /etc/httpd/conf.d/nagios.conf
sed -i 's/AuthUserFile/#AuthUserFile/g' /etc/httpd/conf.d/nagios.conf
sed -i 's/Require valid/#Require valid/g' /etc/httpd/conf.d/nagios.conf

systemctl restart nagios

#To validate configs: Run /usr/sbin/nagios -v /etc/nagios/nagios.cfg.

#Adds repo to known repositories.
echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://10.142.0.7/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo   
