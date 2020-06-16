# Deploying OpenShift 4.3 on Baremetal Server

RedHat Document: https://docs.openshift.com/container-platform/4.3/installing/installing_bare_metal/installing-bare-metal.html
![Architecture](https://github.com/ekambaraml/ocp43-on-baremetal/blob/master/ocp43-deployment.png)


### Cluster Machines and Size

Machine | Count | Operating System | vCPU | RAM | Storage |
--------|-------|------------------|------|-----|---------|
Bootstrap | 1 |  RHCOS | 8 Core | 16GB | 100 GB|
Control Plane (Masters)| 3 | RHCOS | 8 Core | 32 GB | 200 GB |
Compute (Worker) | 3 | RHCOS | 16 Core | 64 GB | 200 GB, 1 TB for Portworx on each worker |
NFS Storage | - | - | - | - | 1 TB |
DHCP/DNS, LoadBalancer | - | - | -|- | On the Host Server |


### Key Components

component | Description |
----------|-------------|
KVM | Kernel Based Virtual Machine, the virtualization layer technology used to provide the VMs on the bare metal host.|
DNSMasq | Combines a DNS forwarder, DHCP server and network boot features that enable new VMs to obtain IP addresses, and load operating systems from a PXE server, and provide DNS services to external and internal addresses.|
iPXE | Implementation of the Preboot eXecution Environment that allows operating systems to be installed via the network.|
Matchbox | A service that matches machine profiles to network boot configurations. This is how a new VM request knows which OS to request the ignition and other setup resources.|
GoBetween | A load balancer |



### Procedure:


### 1. Setup RedHat Openshift subscription
![RH](https://github.com/ekambaraml/ocp43-on-baremetal/blob/master/rh1.png)

### 2. Provision Baremetal Server

![baremetal](https://github.com/ekambaraml/ocp43-on-baremetal/blob/master/baremetal.png)

### 3. Setup DNS Wild Card entry CNAME record

```
*.apps.cluster.example.com
api.cluster.example.com
api-int.cluster.example.com
etcd-1.cluster.example.com (master1)
etcd-2.cluster.example.com (master2)
etcd-3.cluster.example.com (master3)
```

### 4. Clone the Git Repository for Automation
Once the baremetal server is ready, log into the server and clone this githup repository
```
   $ ssh root@<baremetal server>
   $ git clone https://github.com/ekambaraml/ocp43-on-baremetal.git
   
```

### 5. Get pull Secrets

Login into RedHat URL https://cloud.redhat.com/openshift/install for downloading pull secrets and installer.

![RH](https://github.com/ekambaraml/ocp43-on-baremetal/blob/master/rh2.png)

copy pull-secret.json under the ocp43-on-baremetal folder

```
$ cp pull-secret.json ~/ocp43-on-baremetal
```


### 6. Installing OpenShift 4.3

Note: If you are reusing the machine again, Please run the cleanup script to delete previous instance of the cluster nodes with the command below
```
$ cd ~/ocp43-on-baremetal
$ scripts/cleanup-cluster.sh
```

The following command is for creating fresh install

```
$ cd ~/ocp43-on-baremetal

$ ./installocp.sh
```
![Install](https://github.com/ekambaraml/ocp43-on-baremetal/blob/master/ocp43-install.jpg)

![OCP Screen](https://github.com/ekambaraml/ocp43-on-baremetal/blob/master/ocp-43-screen.png)


On successfull completion, this should have created

* [ ] installed required libraries

* [ ] KVM Network

* [ ] DNS/DHCP

* [ ] loadblancer

* [ ] Created KVM vms

* [ ] Storages

* [ ] Installed OpenShift 4.3 Cluster

Now, you can login and test the cluster access


# Detailed description of the step 6 



#### 6.1 Prepare baremetal server

```

$ sh prepare_host.sh
```


#### 6.2 Setup Network

Procedure
* Configure DHCP or set static IP addresses on each node.

* Configure the ports for your machines.

* Configure DNS.

* Ensure network connectivity.

```
$ sh setup-network.sh
```

#### 6.3 Setup Matchbox

```
$ sh setup-matchbox.sh 4.3.8
```

#### 6.4 Setup Installer

```
$ sh setup-installer.sh 4.3.8
```

#### 6.5 Setup Loadbalancer
* Provision the required load balancers.
```
$ sh setup-loadbalancer.sh 
```

#### 6.6 Setup Bootstrap
```
$ sh bootstrap.sh
```

### 7 Setup NFS server
```
$ sh setup-nfs.sh 

```
### 8 Add User

```
$ sh setup-users.sh
```

### 9. Configure Internal Registry


### 10. Attaching Raw disks to VM
Run the commands from the host machine

```
$ virsh attach-disk master1 /dev/sdc  vdb --persistent
$ virsh attach-disk master2 /dev/sdd  vdb --persistent
$ virsh attach-disk master3 /dev/sde  vdb --persistent
$ virsh attach-disk worker1 /dev/sdf  vdb --persistent
$ virsh attach-disk worker2 /dev/sdg  vdb --persistent
$ virsh attach-disk worker3 /dev/sdh  vdb --persistent
```
