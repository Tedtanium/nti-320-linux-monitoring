#!/bin/bash
if [ -e /etc/nagios/objects/commands.cfg ]; then exit 0; fi

yum install nagios nrpe nagios-plugins-all nagios-plugins-nrpe nagios-selinux httpd wget -y

wget https://raw.githubusercontent.com/Tedtanium/nti-320-linux-monitoring/master/automated-network/configs/generate-nagios-client.sh

systemctl enable nagios
systemctl start nagios
systemctl enable nrpe
systemctl start nrpe


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

systemctl restart nagios

#To validate configs: Run /usr/sbin/nagios -v /etc/nagios/nagios.cfg.
