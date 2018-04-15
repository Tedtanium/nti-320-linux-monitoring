#!/bin/bash
apt-get install nagios-nrpe-server nagios-plugins
sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1, 10.142.0.3/g' /etc/nagios/nrpe.cfg
/etc/init.d/nagios-nrpe-server restart
#optional: Use 'systemctl restart <path>' to restart it. 

sed -i "s,command[check_hda1]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/hda1,command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/sda1,g" /etc/nagios/nrpe.cfg

echo "command[check_mem]=/usr/lib/nagios/plugins/check_mem.sh -w 80 -c 90" >> /etc/nagios/nrpe.cfg

# this should happen as part of the packaging of the rpm...
/etc/init.d/nagios-nrpe-server restart
