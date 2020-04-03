#!/bin/bash
# Prepare the baremetal host

function pause(){
   read -p "$*"
}

mkdir -p logs
bash -x ./scripts/prepare_host.sh | tee logs/prepare-host.log

# check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/prepare-host.log"
   exit 1 
fi
pause 'Press [Enter] key to continue...'

# Prepare network
bash -x ./scripts/setup-network.sh | tee logs/setup-network.log

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-network.log"
   exit 1 
fi
pause 'Press [Enter] key to continue...'

# Setup matchbox. 
bash -x ./scripts/setup-matchbox.sh  4.3.8 | tee logs/setup-matchbox.log

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-matchbox.log"
   exit 1 
fi
pause 'Press [Enter] key to continue...'

# Setup OpenShift Installer
bash -x ./scripts/setup-installer.sh 4.3.8 | tee logs/setup-installer.log 

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-installer.log"
   exit 1 
fi
pause 'Press [Enter] key to continue...'

# Setup LoadBalancer
bash -x ./scripts/setup-loadbalancer.sh | tee logs/setup-loadbalancer.sh

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-loadbalancer.log"
   exit 1 
fi
pause 'Press [Enter] key to continue...'

# Install OpenShift
bash -x ./scripts/bootstrap.sh | tee logs/bootstrap.log

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/bootstrap.log"
   exit 1 
fi
pause 'Press [Enter] key to continue...'

# Setup NFS
bash -x ./scripts/setup-nfs.sh | tee logs/setup-nfs.log

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-nfs.log"
   exit 1 
fi
pause 'Press [Enter] key to continue...'

# Setup users 
bash -x ./scripts/setup-users.sh | tee logs/setup-users.log

#check the exit code
if [ $? -eq 1 ]
then
   echo "Error, please check logs/setup-users.log"
   exit 1 
fi

