# Deploying OpenShift 4.3 on Baremetal Server

### Key Components

component | Description |
----------|-------------|
KVM | Kernel Based Virtual Machine, the virtualization layer technology used to provide the VMs on the bare metal host.|
DNSMasq | Combines a DNS forwarder, DHCP server and network boot features that enable new VMs to obtain IP addresses, and load operating systems from a PXE server, and provide DNS services to external and internal addresses.|
iPXE | Implementation of the Preboot eXecution Environment that allows operating systems to be installed via the network.|
Matchbox | A service that matches machine profiles to network boot configurations. This is how a new VM request knows which OS to request the ignition and other setup resources.|
GoBetween | A load balancer |



