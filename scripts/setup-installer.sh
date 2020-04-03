#!/bin/bash
#
# Check the argument for the version of rhcos
if [ $# -ne 1 ]; then
  echo "Usage: $0 <version ex:4.3.8>"
  exit 1
fi

VERSION=4.3.8

# Get the clients
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$VERSION/openshift-client-linux.tar.gz
tar xvf openshift-client-linux.tar.gz
mv oc /usr/local/bin/
mv kubectl /usr/local/bin

# Get the install tool
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$VERSION/openshift-install-linux.tar.gz
tar xvf openshift-install-linux.tar.gz
cp openshift-install /usr/local/bin/

rm openshift-install-linux.tar.gz openshift-client-linux.tar.gz README.md

cd ~/installocp
cp install-config.yaml ../  # backup install-config.yaml 

echo Creating ignition files ....
openshift-install create ignition-configs

# Copy the ignition files
cp *.ign /var/lib/matchbox/ignition

# chmod the files so that they can be accessed
chown -R matchbox:matchbox /var/lib/matchbox

# make a backup of kubeconfig
cp auth/kubeconfig auth/kubeconfig.bk

# Create the VMs
virsh vol-create-as uvtool bootstrap.qcow2 100G
virt-install --name=bootstrap --ram=16000 --vcpus=8 --mac=52:54:00:02:85:01 \
--disk path=/var/lib/uvtool/libvirt/images/bootstrap.qcow2,bus=virtio \
--pxe --noautoconsole --graphics=vnc --hvm \
--network network=ocp,model=virtio --boot hd,network

virsh vol-create-as uvtool master1.qcow2 200G
virt-install --name=master1 --ram=65536 --vcpus=16 --mac=52:54:00:02:86:01 \
--disk path=/var/lib/uvtool/libvirt/images/master1.qcow2,bus=virtio \
--pxe --noautoconsole --graphics=vnc --hvm \
--network network=ocp,model=virtio --boot hd,network


virsh vol-create-as uvtool master2.qcow2 200G
virt-install --name=master2 --ram=65536 --vcpus=16 --mac=52:54:00:02:86:02 \
--disk path=/var/lib/uvtool/libvirt/images/master2.qcow2,bus=virtio \
--pxe --noautoconsole --graphics=vnc --hvm \
--network network=ocp,model=virtio --boot hd,network


virsh vol-create-as uvtool master3.qcow2 200G
virt-install --name=master3 --ram=65536 --vcpus=16 --mac=52:54:00:02:86:03 \
--disk path=/var/lib/uvtool/libvirt/images/master3.qcow2,bus=virtio \
--pxe --noautoconsole --graphics=vnc --hvm \
--network network=ocp,model=virtio --boot hd,network


virsh vol-create-as uvtool worker1.qcow2 200G
virt-install --name=worker1 --ram=65536 --vcpus=16 --mac=52:54:00:02:87:01 \
--disk path=/var/lib/uvtool/libvirt/images/worker1.qcow2,bus=virtio \
--pxe --noautoconsole --graphics=vnc --hvm \
--network network=ocp,model=virtio --boot hd,network


virsh vol-create-as uvtool worker2.qcow2 200G
virt-install --name=worker2 --ram=65536 --vcpus=16 --mac=52:54:00:02:87:02 \
--disk path=/var/lib/uvtool/libvirt/images/worker2.qcow2,bus=virtio \
--pxe --noautoconsole --graphics=vnc --hvm \
--network network=ocp,model=virtio --boot hd,network


virsh vol-create-as uvtool worker3.qcow2 200G
virt-install --name=worker3 --ram=65536 --vcpus=16 --mac=52:54:00:02:87:03 \
--disk path=/var/lib/uvtool/libvirt/images/worker3.qcow2,bus=virtio \
--pxe --noautoconsole --graphics=vnc --hvm \
--network network=ocp,model=virtio --boot hd,network


# Check if the VMs have shutdown

sleep 30
count=`virsh list --all | grep -i running | wc -l`
while [ $count -ne 0 ]
do
  sleep 10
  count=`virsh list --all | grep -i running | wc -l`
done
