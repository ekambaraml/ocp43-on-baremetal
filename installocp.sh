#!/bin/bash

echo "**************************************************************\n"
echo "O P E N S H I F T  4.3  O N  B A R E M E T A L  S E R V E R \n"
echo "**************************************************************\n"

date
# Prepare the baremetal host
echo "\n\n 1. Preparing the baremetal host "
echo "**************************************************************\n"
mkdir -p logs
bash -x ./scripts/prepare_host.sh | tee logs/prepare-host.log

# check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/prepare-host.log"
   exit 1 
fi

# Prepare network
echo "\n\n 2. Preparing network (DNS/DHCP)" 
echo "**************************************************************\n"
bash -x ./scripts/setup-network.sh | tee logs/setup-network.log

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-network.log"
   exit 1 
fi

# Setup matchbox. 
echo "\n\n 3. Setting up  matchbox server " 
echo "**************************************************************\n"
bash -x ./scripts/setup-matchbox.sh  4.3.8 | tee logs/setup-matchbox.log

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-matchbox.log"
   exit 1 
fi

# Setup OpenShift Installer
echo "\n\n 4. Creating KVM vms, storages "
echo "**************************************************************\n"
bash -x ./scripts/setup-installer.sh 4.3.8 | tee logs/setup-installer.log 

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-installer.log"
   exit 1 
fi

# Setup LoadBalancer
echo "\n\n 5. LoadBalancer setup"
echo "**************************************************************\n"
bash -x ./scripts/setup-loadbalancer.sh | tee logs/setup-loadbalancer.sh

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-loadbalancer.log"
   exit 1 
fi

# Install OpenShift
echo "\n\n 6.Installing Openshift"
echo "**************************************************************\n"
echo "It will take about 20 minutes ..."
bash -x ./scripts/bootstrap.sh | tee logs/bootstrap.log

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/bootstrap.log"
   exit 1 
fi

# Setup NFS
# bash -x ./scripts/setup-nfs.sh | tee logs/setup-nfs.log

#check the exit code
# if [ $? -eq 1 ]
# then
#    echo "Error, please check logs/setup-nfs.log"
#    exit 1 
# fi

# Setup users 
# bash -x ./scripts/setup-users.sh | tee logs/setup-users.log

#check the exit code
# if [ $? -eq 1 ]
# then
#    echo "Error, please check logs/setup-users.log"
#    exit 1 
# fi

date
