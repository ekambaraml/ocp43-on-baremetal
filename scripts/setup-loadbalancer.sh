#!/bin/bash
cd ~
wget https://github.com/yyyar/gobetween/releases/download/0.7.0/gobetween_0.7.0_linux_amd64.tar.gz

mkdir ~/gobetween
cd ~/gobetween
tar xvf ../gobetween_0.7.0_linux_amd64.tar.gz
cp gobetween /usr/local/bin/

cd ~
rm -rf gobetween gobetween_0.7.0_linux_amd64.tar.gz

# Create gobetween service

cat > /etc/systemd/system/gobetween.service << EOF
[Unit]
Description=Gobetween - modern LB for cloud era
Documentation=https://github.com/yyyar/gobetween/wiki
After=network.target 

[Service]
Type=simple
PIDFile=/run/gobetween.pid
#ExecStartPre=prestart some command
ExecStart=/usr/local/bin/gobetween -c /etc/gobetween/gobetween.toml
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/gobetween
cp ~/ocp43-on-baremetal/gobetween/gobetween.toml /etc/gobetween/gobetween.toml
systemctl enable gobetween; systemctl start gobetween

# Copy cluster.conf and restart dnsmasq service
myurl=blueonca.ibmcloudpack.com
cp ~/ocp43-on-baremetal/dnsmasq/cluster.conf /etc/dnsmasq.d/cluster.conf
sed -i "s/mycluster.example.com/$myurl/g" /etc/dnsmasq.d/cluster.conf

systemctl restart dnsmasq
