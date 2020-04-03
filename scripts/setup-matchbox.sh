#!/bin/bash
# Setup matchbox
# Check the argument for the version of rhcos
if [ $# -ne 1 ]; then
  echo "Usage: $0 <version ex:4.3.8>"
  exit 1
fi

VERSION=4.3.8
SVER=latest
myurl=blueonca.ibmcloudpack.com

cd ~
wget https://github.com/poseidon/matchbox/releases/download/v0.8.3/matchbox-v0.8.3-linux-amd64.tar.gz
tar zxvf matchbox-v0.8.3-linux-amd64.tar.gz
cp matchbox-v0.8.3-linux-amd64/matchbox /usr/local/bin
chmod 755 /usr/local/bin/matchbox

useradd -U matchbox
mkdir -p /var/lib/matchbox/assets
mkdir -p /var/lib/matchbox/groups
mkdir -p /var/lib/matchbox/ignition
mkdir -p /var/lib/matchbox/profiles
chown -R matchbox:matchbox /var/lib/matchbox
cp matchbox-v0.8.3-linux-amd64/contrib/systemd/matchbox-local.service /etc/systemd/system/matchbox.service

systemctl enable matchbox; systemctl start matchbox

# Clean up the matchbox files and folders
rm -rf matchbox-v0.8.3-linux-amd64
rm -rf matchbox-v0.8.3-linux-amd64.tar.gz

# Get the required images 
# This may have to change with the changing versions of OpenShift
# Check https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.3/
#

cd /var/lib/matchbox/assets
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/$SVER/latest/rhcos-$VERSION-x86_64-installer-initramfs.x86_64.img
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/$SVER/latest/rhcos-$VERSION-x86_64-installer-kernel-x86_64
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/$SVER/latest/rhcos-$VERSION-x86_64-metal.x86_64.raw.gz

cd /var/lib/matchbox/groups
cp ~/ocp43-on-baremetal/matchbox/groups/* .

cd /var/lib/matchbox/profiles
cp ~/ocp43-on-baremetal/matchbox/profiles/* .

# Modify profiles with the right version of boot strapping. For 4.3.x, the suffix x86_64 is added. It is not there for 4.2.x. Modify accordingly


sed -i "s/rhcos-4.2.0-x86_64-installer-kernel/rhcos-$VERSION-x86_64-installer-kernel-x86_64/g" *.json
sed -i "s/rhcos-4.2.0-x86_64-installer-initramfs.img/rhcos-$VERSION-x86_64-installer-initramfs.x86_64.img/g" *.json
sed -i "s/rhcos-4.2.0-x86_64-metal-bios.raw.gz/rhcos-$VERSION-x86_64-metal.x86_64.raw.gz/g" *.json

sed -i "s/mycluster.example.com/$myurl/g" *.json

chown -R matchbox:matchbox /var/lib/matchbox
