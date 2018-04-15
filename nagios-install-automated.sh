#!/bin/bash
yum install nagios -y
systemctl enable nagios
systemctl start nagios
yum install -y httpd
setenforce 0
systemctl enable httpd
systemctl start httpd
yum install -y nrpe
systemctl enable nrpe
systemctl start nrpe
yum install nagios-plugins-all
yum -y install nagios-plugins-nrpe

yum install -y nagios-selinux 
systemctl restart nagios
setenforce 1
