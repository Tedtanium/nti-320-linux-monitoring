#!/bin/bash

yum install net-tools -y
sed -i 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf
sed -i 's/#$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf
sed -i 's/#$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf

systemctl restart rsyslog

#For clients: echo "*.info;mail.none;authpriv.none;cron.none   @<IP ADDR>" >> /etc/rsyslog.conf && systemctl restart rsyslog.service
