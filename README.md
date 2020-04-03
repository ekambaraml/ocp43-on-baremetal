# Deploying OpenShift 4.3 on Baremetal Server

![Architecture](https://github.com/ekambaraml/ocp43-on-baremetal/blob/master/ocp43-deployment.png)

### Key Components

component | Description |
----------|-------------|
KVM | Kernel Based Virtual Machine, the virtualization layer technology used to provide the VMs on the bare metal host.|
DNSMasq | Combines a DNS forwarder, DHCP server and network boot features that enable new VMs to obtain IP addresses, and load operating systems from a PXE server, and provide DNS services to external and internal addresses.|
iPXE | Implementation of the Preboot eXecution Environment that allows operating systems to be installed via the network.|
Matchbox | A service that matches machine profiles to network boot configurations. This is how a new VM request knows which OS to request the ignition and other setup resources.|
GoBetween | A load balancer |



### Steps:


### 1. Setup RedHat Openshift subscription

### 2. Provision Baremetal Server

Once the baremetal server is ready, log into the server and clone this githup repository
```
   $ ssh root@<baremetal server>
   $ git clone https://github.com/ekambaraml/ocp43-on-baremetal.git
   
```

### 3. Get pull Secrets

### 4. Prepare baremetal server

### 5. Setup Network

### 6. Setup Matchbox

### 7. Setup Installer

### 8. Setup Loadbalancer

### 9. Setup Bootstrap

### 10. Setup NFS server

### 11. Add User

### 12. Configure Internal Registry

