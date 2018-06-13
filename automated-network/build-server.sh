#Installation stuff.

yum install rpm-build make gcc git wget -y

#Creates directory for RPM.

mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

#Pulls down the tarball for the package. Place it in the SOURCES directory. When automating, use wget -P.
#wget https://github.com/nic-instruction/NTI-320/blob/master/rpm-info/hello_world_from_source/helloworld-0.1.tar.gz?raw=true -P /root/rpmbuild/SOURCES

#Pull down or make a shell file. Put it in SOURCES.
wget https://raw.githubusercontent.com/nic-instruction/NTI-320/master/rpm-info/hello_world_from_source/helloworld.sh -P /root/rpmbuild/SOURCES

#Pull down hello.spec. Put it in the SPECS directory.

#wget https://raw.githubusercontent.com/nic-instruction/NTI-320/master/rpm-info/hello_world_from_source/hello.spec -P /root/rpmbuild/SPECS

#Builds an RPM file out of the specs This is put in the RPMS directory.

rpmbuild -v -bb --clean /root/rpmbuild/SPECS/hello.specs

#Change to RPMS directory before doing this when manually installing.

yum install /root/rpmbuild/RPMS/x86_64/helloworld-0.1-1.el7.centos.x86_64.rpm -y

#Adds repo to known repositories.
echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://10.142.0.7/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo   
