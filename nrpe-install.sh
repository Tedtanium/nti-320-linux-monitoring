#!/bin/bash
apt-get install nagios-nrpe-server nagios-plugins
sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1, 10.142.0.3/g' /etc/nagios/nrpe.cfg
/etc/init.d/nagios-nrpe-server restart
#optional: Use 'systemctl restart <path>' to restart it. 
