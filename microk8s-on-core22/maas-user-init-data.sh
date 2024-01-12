#!/bin/bash
(
echo === $date ===
echo "importing ssh ids"
sudo apt install jq -y
for id in $(curl -s https://api.launchpad.net/1.0/~fe-team/members | jq -r '.entries[] | .name'); do ssh-import-id-lp $id; done

echo "download microk8s-core-22 image from tebbutt"
wget http://172.16.7.12/iotdevice-microk8s-demo-amd64.qcow2 -P /home/ubuntu/
wget http://172.16.7.12/ubuntu-core-22-amd64.lxd.tar.xz -P /home/ubuntu/

echo "lxd init with preseed"
cat <<EOF | lxd init --preseed
config:
  images.auto_update_interval: 15
networks:
- name: lxdbr0
  type: bridge
  config:
    ipv4.address: auto
    ipv6.address: none
storage_pools:
- config:
    size: 300GiB
  description: ""
  name: default
  driver: zfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
cluster: null
EOF

echo "checking lxd config"
lxd init --dump

echo "import image to lxc"
lxc image import ubuntu-core-22-amd64.lxd.tar.xz iotdevice-microk8s-demo-amd64.qcow2  --alias microk8s-core-22

echo "check list of images"
lxc image list

echo "launch 6 vms"
for f in $(seq 1 6); do
  lxc init microk8s-core-22 microk8s-$f \
    --vm -d root,size=15GiB -c limits.memory=8GB \
    -c limits.cpu=4 -c security.secureboot=true
  lxc config device add microk8s-$f tpm tpm path=/dev/tpm0
  lxc start microk8s-$f
done


) | tee /home/ubuntu/cloudinit-maas-userdata.log
