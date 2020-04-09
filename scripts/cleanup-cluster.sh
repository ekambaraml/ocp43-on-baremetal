#!/bin/bash
# Cleanup Cluster


# Delete vms
virsh destroy --domain bootstrap
virsh destroy --domain master1
virsh destroy --domain master2
virsh destroy --domain master3
virsh destroy --domain worker1
virsh destroy --domain worker2
virsh destroy --domain worker3

virsh undefine --domain bootstrap
virsh undefine --domain master1
virsh undefine --domain master2
virsh undefine --domain master3
virsh undefine --domain worker1
virsh undefine --domain worker2
virsh undefine --domain worker3

# Delete VM
echo "deleting storages..."
virsh vol-delete  --pool uvtool  bootstrap.qcow2
virsh vol-delete  --pool uvtool  master1.qcow2
virsh vol-delete  --pool uvtool  master2.qcow2
virsh vol-delete  --pool uvtool  master3.qcow2
virsh vol-delete  --pool uvtool  worker1.qcow2
virsh vol-delete  --pool uvtool  worker2.qcow2
virsh vol-delete  --pool uvtool  worker3.qcow2


# Delete network
echo "deleteing network ocp"
virsh net-destroy ocp
virsh net-undefine ocp



systemctl stop dnsmasq
systemctl stop gobetween
systemctl stop matchbox
apt remove -y dnsmasq
rm  /var/lib/misc/dnsmasq.leases
rm -rf /var/lib/matchbox
rm -rf ~/installocp
rm -rf ~/.ssh/id_rs*
echo "nameserver  8.8.8.8" > /etc/resolv.conf
