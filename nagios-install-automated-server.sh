#!/bin/bash
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

echo '########### NRPE CONFIG LINE #######################
define command{
command_name check_nrpe
command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}' >> /etc/nagios/objects/commands.cfg
