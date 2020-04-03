#!/bin/bash
#Start the VMs

virsh start bootstrap
virsh start master1
virsh start master2
virsh start master3
virsh start worker1
virsh start worker2
virsh start worker3

sleep 120

# Kick of the bootstrap
cd ~/installocp
openshift-install --dir=. wait-for bootstrap-complete --log-level=debug 

# Once it comes to the command prompt check the log to see if it was successful
grep "INFO it is now safe to remove the bootstrap resources" .openshift_install.log
if [ true ]; then

  # update cluster.conf by commenting bootstrap server
  sed -i "s/^[^#]*192.168.10.152/#&/" /etc/dnsmasq.d/cluster.conf
  sed -i "s/^[^#]*152.10.168.192/#&/" /etc/dnsmasq.d/cluster.conf

  # Restart dnsmasq
  systemctl restart dnsmasq

  # Update gobetween by removing the bootstrap entries
  sed -i "s/,\"192.168.10.152:22623\"//g" /etc/gobetween/gobetween.toml
  sed -i "s/,\"192.168.10.152:6443\"//g" /etc/gobetween/gobetween.toml

  # Restart gobetween
  systemctl restart gobetween

  # Patch openshift-image-registry to an empty dir to complete the installation. 
  # Add wait for the config to be available
  sleep 300
  export KUBECONFIG=~/installocp/auth/kubeconfig
  output=`oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'`
 
  # Check the output from the above command
  if [ $(output) =~ "cluster not found" ]; then
    sleep 120
    oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'
  fi

  # Continue with install
  cd ~/installocp
  openshift-install --dir=. wait-for install-complete --log-level=debug
  echo "Install complete.."
fi
