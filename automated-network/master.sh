#!/bin/bash

if [ -e /django-server-auto.sh ]; then exit 0; fi


############# GCLOUDAPI ###################
#Gets GCloud ready to go.
gcloud init
1
nti-320-200300


################# GIT ####################
#Pulls down repository.
yum install git -y
git clone https://github.com/Tedtanium/nti-320-linux-monitoring.git

####### INSTANCE STARTUP BUILD REGION ########


#For loop - Runs through a gotten list (for line in) - /nti-320-linux-monitoring/automated-network/configs/instances-list
  gcloud compute instances create $HOSTNAME	--metadata-from-file startup-script=NTI-320-linux-monitoring/automated-network/$HOSTNAME.sh --image centos-7 --tags http-server --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 

  IP=$(getent hosts <servername>.c.nti-320-200300.internal | awk '{ print $1 }')
#Runs the Nagios client creation script on the Nagios server, passing hostname and IP variables as arguments.
  gcloud compute ssh root@nagios --command "bash /generate-nagios-client.sh $HOSTNAME $IP"
  
  #if statements go here - Checks for conditions, primarily what $HOSTNAME is, and checks it against whether or not it is a
  #hostname that requires an IP to be extracted, or pushed in somewhere.


###########################################



###########################################
############ NTI-310 SECTION ##############
###########################################

################ LDAP #####################
#Target file: automated-network/ldap-server.sh
#A variable will be collected: $LDAPIP

#Execution line.
gcloud compute instances create ldap-server	--metadata-from-file startup-script=nti-310-linux-enterprise-applications/automated-network/ldap-server.sh --image centos-7 --tags http-server --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 



LDAPIP=$(getent hosts ldap-server.c.nti-320-200300.internal | awk '{ print $1 }')


#Verifies that the variable is being stored.
echo $LDAPIP > ldapip.txt



################ NFS ######################
#Secondly, the NFS server needs to be made.
#Target file: automated-network/nfs-server.sh
#A variable will be collected: $NFSIP


#Execution line.
gcloud compute instances create nfs-server	--metadata-from-file startup-script=nti-310-linux-enterprise-applications/automated-network/nfs-server.sh --image centos-7 --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 

NFSIP=$(getent hosts nfs-server.c.nti-320-200300.internal | awk '{ print $1 }')

echo $NFSIP > nfsip.txt



############## CLIENT #####################
#Third comes the LDAP/NFS clients.
#Target file: automated-network/client.sh
#Variables needed: $LDAPIP, $NFSIP


#Note to self: Debconf MUST be integrated into client install! Made independently of the LDAP server.

#sed line - should replace all instances of LDAPIP with $LDAPIP.
sed -i "s/LDAPIP/$LDAPIP/g" /nti-310-linux-enterprise-applications/automated-network/client.sh 

#sed line - should replace all instances of NFSIP with $NFSIP.
sed -i "s/NFSIP/$NFSIP/g" /nti-310-linux-enterprise-applications/automated-network/client.sh 


#Execution lines.
gcloud compute instances create client-a	--metadata-from-file startup-script=nti-310-linux-enterprise-applications/automated-network/client.sh --image-family ubuntu-1604-lts --image-project ubuntu-os-cloud --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 
gcloud compute instances create client-b	--metadata-from-file startup-script=nti-310-linux-enterprise-applications/automated-network/client.sh --image-family ubuntu-1604-lts --image-project ubuntu-os-cloud --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 


############ POSTGRES ####################
#Fourth is a Postgres server.
#Target file: automated-network/postgres.sh
#A variable will be collected: $POSTGRESIP

#Execution line.
gcloud compute instances create postgres	--metadata-from-file startup-script=nti-310-linux-enterprise-applications/automated-network/postgres.sh --image centos-7 --tags http-server --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 

POSTGRESIP=$(getent hosts postgres.c.nti-320-200300.internal | awk '{ print $1 }')

echo $POSTGRESIP > postgresip.txt


########### DJANGO ######################
#Fifth and finally, a Django server.
#Target file: automated-network/django.sh
#A variable will be needed: $POSTGRESIP

#Additional edits will have to be made to this script (settings.py cannot rely on external file).
#sed line - should replace all instances of POSTGRESIP with $POSTGRESIP.
sed -i "s/POSTGRESIP/$POSTGRESIP/g" /nti-310-linux-enterprise-applications/automated-network/django.sh

#Creates a firewall rule for port 8000 TCP, to be used in Django.
gcloud compute firewall-rules create djangoisonfiresomebodycall911 --allow tcp:8000
# ^ This fails and aborts the script if it already exists, so it can be commented out here.


#Execution line.
gcloud compute instances create django --metadata-from-file startup-script=nti-310-linux-enterprise-applications/automated-network/django.sh --image centos-7 --tags "http-server","djangoisonfiresomebodycall911" --zone us-east1-b --machine-type f1-micro --scopes cloud-platform 

############## LOAD BALANCER ##############
#Spins up the load balancer.
#Target file: automated-network/load-balancer.sh
#Execution line.
gcloud compute instances create load-balancer	--metadata-from-file startup-script=nti-310-linux-enterprise-applications/automated-network/load-balancer.sh --image centos-7 --tags http-server --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 
