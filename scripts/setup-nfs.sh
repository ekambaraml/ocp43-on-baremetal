#!/bin/bash
# Create the VM

cd ~
uvt-kvm create nfs-server release=bionic --memory 4096 --cpu 4 --disk 550 --bridge br-ocp
#uvt-kvm wait nfs-server --insecure

# Wait for 2 minutes for the VM to be ready and get an IPAddress
sleep 120
ipaddress=`grep ubuntu /var/lib/misc/dnsmasq.leases | awk '{print $3}'`
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$ipaddress "sudo apt install -y nfs-kernel-server"
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$ipaddress "sudo mkdir /var/nfs/general -p; sudo chown nobody:nogroup /var/nfs/general;" 

# Create exports to copy to nfs-server
cat > /tmp/exports << EOF
/var/nfs/general    *(rw,sync,no_subtree_check,no_root_squash)
EOF

# Copy the file and start nfs server
scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/exports ubuntu@$ipaddress:/tmp
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$ipaddress "sudo cp /tmp/exports /etc; sudo cat /etc/exports; sudo systemctl enable nfs-kernel-server; sudo systemctl restart nfs-kernel-server"

# Configure NFS as a Managed Storage class
mkdir -p /var/nfsshare
mount -t nfs $ipaddress:/var/nfs/general /var/nfsshare
cd ~
mkdir -p nfs
cd nfs
cp ~/ocp43-on-baremetal/nfs/* .
sed -i "s/<< IP ADDRESS OF NFS SERVER VM>>/$ipaddress/g" deployment.yaml

export KUBECONFIG=~/installocp/auth/kubeconfig

# Create a new project for NFS
oc new-project nfs-fs
oc -n nfs-fs create -f rbac.yaml
oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:nfs-fs:nfs-client-provisioner
oc -n nfs-fs create -f class.yaml
oc -n nfs-fs create -f deployment.yaml

oc patch storageclass managed-nfs-storage -p '{"metadata": {"annotations":  {"storageclass.kubernetes.io/is-default-class": "true"}}}'

# Update imageregistry config to use nfs
oc patch configs.imageregistry.operator.openshift.io cluster --type=json --patch '[{"op":"remove","path":"/spec/storage/emptyDir"},{"op":"add","path":"/spec/storage/pvc","value":{"claim":""}}]'

# expose registry
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
