Name:		startup
Version: 	0.1
Release:	1%{?dist}
Summary: 	A collection of configuration changes

Group:		NTI-320
License:	GPL2+
URL:		https://github.com/nic-instruction/hello-NTI-320
Source0:        https://github.com/nic-instruction/hello-NTI-320/startup-0.1.tar.gz

BuildRequires:	gcc, python >= 1.3
Requires:	bash, net-snmp, net-snmp-utils, nrpe, nagios-plugins-all

%description
This package contains customization for a monitoring server, a trending server and a   logserver on the nti320 network.

%prep
%setup -q	
		
%build					
%define _unpackaged_files_terminate_build 0

%install

rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/lib64/nagios/plugins/
mkdir -p %{buildroot}/etc/nrpe.d/

install -m 0755 startup.sh %{buildroot}/usr/lib64/nagios/plugins/

#install -m 0744 nti320.cfg %{buildroot}/etc/nrpe.d/

%clean

%files					
%defattr(-,root,root)	
/usr/lib64/nagios/plugins/startup.sh


%config
#/etc/nrpe.d/nti320.cfg

%doc			



%post

#######Nagios client.######
yum install nrpe-selinux -y
yum install nrpe -y
yum install nagios-plugins-all -y
sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1, NAGIOSIP/g' /etc/nagios/nrpe.cfg
sed -i "s,command[check_hda1]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/hda1,command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/sda1,g" /etc/nagios/nrpe.cfg

#####Cacti client.######
yum install -y net-snmp
apt-get install snmp -y
systemctl enable snmpd
systemctl start snmpd

########Syslog client.######
yum install net-tools -y
sed -i 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf
sed -i 's/#$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf
sed -i 's/#$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf
systemctl restart rsyslog
echo "*.info;mail.none;authpriv.none;cron.none   @RSYSLOGIP" >> /etc/rsyslog.conf && systemctl restart rsyslog.service


touch /thisworked2
systemctl enable snmpd
systemctl start snmpd
sed -i 's,/dev/hda1,/dev/sda1,'  /etc/nagios/nrpe.cfg

%postun
echo "We didn't actually remove everything. Have fun cleaning it up!"
rm /thisworked2
#rm /etc/nrpe.d/nti320.cfg
%changelog				# changes you (and others) have made and why
