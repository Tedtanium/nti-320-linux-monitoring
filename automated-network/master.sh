#!/bin/bash

if [ -e /NTI-320-linux-monitoring ]; then exit 0; fi


############# GCLOUDAPI ###################
#Gets GCloud ready to go.
gcloud init
1
nti-320-200300


################# GIT ####################
#Pulls down repository.
yum install git -y
git clone https://github.com/Tedtanium/nti-320-linux-monitoring.git

####### FIREWALL RULE CREATION #######
#gcloud compute firewall-rules create djangoisonfiresomebodycall911 --allow tcp:8000
# ^ Needs to be run once, will error if it already exists.


########## For loop. #########################
#Runs a whole ton of instances with conditions.
for line in $(cat /nti-320-linux-monitoring/automated-network/configs/instances-list); do
  HOSTNAME=$line

########## IF STATEMENTS ######################
#These check to see if $HOSTNAME matches the case. If so, it launches the instance with required conditions.
  
  if [ $HOSTNAME = 'nagios' ]; then
    gcloud compute instances create nagios	--metadata-from-file startup-script=nti-320-linux-monitoring/automated-network/nagios.sh --image centos-7 --tags http-server --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 
    sleep 4m
  fi
  
  if [ $HOSTNAME = 'ldap' ]; then
    gcloud compute instances create ldap	--metadata-from-file startup-script=nti-320-linux-monitoring/automated-network/ldap.sh --image centos-7 --tags http-server --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 
    LDAPIP=$(getent hosts $HOSTNAME.c.nti-320-200300.internal | awk '{ print $1 }')
    sed -i "s/LDAPIP/$LDAPIP/g" /nti-320-linux-monitoring/automated-network/client.sh 
  fi
  
  
  if [ $HOSTNAME = 'nfs' ]; then
    gcloud compute instances create nfs	--metadata-from-file startup-script=nti-320-linux-monitoring/automated-network/nfs.sh --image centos-7 --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 
    NFSIP=$(getent hosts $HOSTNAME.c.nti-320-200300.internal | awk '{ print $1 }')
    sed -i "s/NFSIP/$NFSIP/g" /nti-320-linux-monitoring/automated-network/client.sh 
  fi
  
  
  if [ $HOSTNAME = 'postgres' ]; then
    gcloud compute instances create postgres	--metadata-from-file startup-script=nti-320-linux-monitoring/automated-network/postgres.sh --image centos-7 --tags http-server --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 
    POSTGRESIP=$(getent hosts $HOSTNAME.c.nti-320-200300.internal | awk '{ print $1 }')
    sed -i "s/POSTGRESIP/$POSTGRESIP/g" /nti-320-linux-monitoring/automated-network/django.sh 
  fi
  
  
  if [ $HOSTNAME = 'django' ]; then
    gcloud compute instances create django --metadata-from-file startup-script=nti-320-linux-monitoring/automated-network/django.sh --image centos-7 --tags "http-server","djangoisonfiresomebodycall911" --zone us-east1-b --machine-type f1-micro --scopes cloud-platform 
  fi
  
  
  if [ $HOSTNAME = 'load-balancer' ]; then 
    gcloud compute instances create load-balancer	--metadata-from-file startup-script=nti-320-linux-monitoring/automated-network/load-balancer.sh --image centos-7 --tags http-server --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 
  fi
  
  
  if [ $HOSTNAME = 'client' ]; then
    gcloud compute instances create client-a	--metadata-from-file startup-script=nti-320-linux-monitoring/automated-network/client.sh --image-family ubuntu-1604-lts --image-project ubuntu-os-cloud --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 
    gcloud compute instances create client-b	--metadata-from-file startup-script=nti-320-linux-monitoring/automated-network/client.sh --image-family ubuntu-1604-lts --image-project ubuntu-os-cloud --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform
  fi
  
  if [ $HOSTNAME != 'ldap' ] && [ $HOSTNAME != 'nfs' ] && [ $HOSTNAME != 'postgres' ] && [ $HOSTNAME != 'django' ] && [ $HOSTNAME != 'load-balancer' ] && [ $HOSTNAME != 'client' ] && [ $HOSTNAME != 'nagios' ]; then
    gcloud compute instances create $HOSTNAME	--metadata-from-file startup-script=nti-320-linux-monitoring/automated-network/$HOSTNAME.sh --image centos-7 --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform    
  fi
  
  if [ $HOSTNAME != 'nagios' ]; then
    IP=$(getent hosts $HOSTNAME.c.nti-320-200300.internal | awk '{ print $1 }')
    #Runs the Nagios client creation script on the Nagios server, passing hostname and IP variables as arguments.
    gcloud compute ssh root@nagios --command "bash /generate-nagios-client.sh $HOSTNAME $IP"
  fi
  
done

