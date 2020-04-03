#!/bin/bash
# Assumes the hostname is set and the public ip address is configured
# Install the required filesets

apt update
apt install -y net-tools curl nano tree wget jq nfs-common cpu-checker

# Check if the system can run the virtualization
if ! kvm-ok | grep -L "KVM acceleration can be used"; then
  echo "KVM Cannot be run on this system"
  exit 1
fi

# Install KVM and uvtool
apt install -y libosinfo-bin qemu qemu-kvm libvirt-bin bridge-utils virt-manager uvtool

#Enable and start KVM
systemctl enable libvirtd; systemctl start libvirtd

#Install basic ubuntu image for uvtool to create loadbalancer and nfs server
uvt-simplestreams-libvirt --verbose sync release=bionic arch=amd64

#Create ssh key
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -N ""

# Variable for sshkey
mysshkey="sshKey: `cat ~/.ssh/id_rsa.pub`"

# Assumes the template files are available in ~/install_ocp42/files directory
# Assumes the RH pull secret is available as pull-secret.json
# Variable for pull secret
mypullsecret="pullSecret: '`cat ~/ocp43-on-baremetal/pull-secret.json`'"

# Prepare install-config.yaml
# Replace pullSecret
mkdir -p ~/installocp
cd ~/installocp
cp ~/ocp43-on-baremetal/install-config.yaml .
sed -i "s/.*pullSecret.*/$mypullsecret/g" install-config.yaml

#Add sshkey to the install-config.yaml
sed -i "s/.*sshKey.*//g" install-config.yaml
echo $mysshkey >> install-config.yaml

myurl=`hostname -s`
sed -i "s/mycluster/$myurl/g" install-config.yaml

# Make a backup of install-config.yaml
cp install-config.yaml backup-install-config.yaml

# Get OpenShift CLI tools
#
# Try to get the latest client
#
#cd ~
#wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.3.5/openshift-client-linux.tar.gz 

#tar xvf openshift-client-linux.tar.gz
#mv oc /usr/local/bin/
#mv kubectl /usr/local/bin

#rm openshift-client-linux.tar.gz README.md

# Get the installer. Again try to get the latest.
#
#wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.3.5/openshift-install-linux.tar.gz
#tar xvf openshift-install-linux.tar.gz
#cp openshift-install /usr/local/bin/

#rm openshift-install-linux.tar.gz README.md
