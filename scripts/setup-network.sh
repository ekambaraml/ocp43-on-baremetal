#!/bin/bash
# Setup network for VMs
cat > net_ocp.xml << EOF
<network>
   <name>ocp</name>
   <forward mode='nat'/>
   <bridge name='br-ocp' stp='on' delay='0'/>
   <dns enable="no"/> 
   <ip address='192.168.10.1' netmask='255.255.255.0'>
   </ip>
</network>
EOF

# Configure the KVM
virsh net-define net_ocp.xml
virsh net-autostart ocp
virsh net-start ocp

systemctl restart libvirt-bin

#Check if the network exists
inetaddr=`ifconfig br-ocp | grep inet | awk '{print $2}'`
if [[ "$inetaddr" != "192.168.10.1" ]]; then
  echo "KVM network config is incomplete"
  exit
fi

#
# Setup DNSMasq/ipxe/tftp 
#
# Setup iPXE server
apt-get -y  install tftp 
apt -y install ipxe
mkdir -p /var/lib/tftp
cp /usr/lib/ipxe/undionly.kpxe /var/lib/tftp
cp /usr/lib/ipxe/ipxe.efi /var/lib/tftp
chown dnsmasq:nogroup /var/lib/tftp/*

# Install DNSMasq
apt install -y dnsmasq
systemctl enable dnsmasq; systemctl start dnsmasq

# configure dnsmasq.conf
cp ~/ocp43-on-baremetal/dnsmasq/dnsmasq.conf /etc/
myurl=`hostname -f`
sed -i "s/mycluster.example.com/$myurl/g" /etc/dnsmasq.conf

rm -rf /var/lib/misc/dnsmasq.leases
touch /var/lib/misc/dnsmasq.leases

# Update /etc/resolv.conf
cat > /etc/resolv.conf << EOF
nameserver 127.0.0.1
EOF

systemctl restart dnsmasq

# Update dns server 
sed -i "s/#DNS=/DNS=127.0.0.1/g" /etc/systemd/resolved.conf

# Update /etc/netplan/01-netcfg.yaml
# Use yq to update the file and is a multi-step process
# Install yq
apt install -y snapd
snap install yq
export PATH=$PATH:/snap/bin

cp /etc/netplan/01-netcfg.yaml /tmp/01-netcfg.yaml

cat /tmp/01-netcfg.yaml | yq d - network.bonds.bond0.nameservers.addresses[1] > /tmp/01-netcfg1.yaml
cat /tmp/01-netcfg1.yaml | yq w - network.bonds.bond0.nameservers.addresses[0] 127.0.0.1 > /tmp/01-netcfg.yaml
cat /tmp/01-netcfg.yaml | yq d - network.bonds.bond1.nameservers.addresses[1] > /tmp/01-netcfg1.yaml
cat /tmp/01-netcfg1.yaml | yq w - network.bonds.bond1.nameservers.addresses[0] 127.0.0.1 > /tmp/01-netcfg.yaml

# Copy the updated file back to /etc/netplan
cp /tmp/01-netcfg.yaml /etc/netplan/01-netcfg.yaml
netplan apply

systemctl restart systemd-resolved
