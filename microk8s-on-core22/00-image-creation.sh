sudo apt install qemu-utils -y
wget http://cdimages.ubuntu.com/ubuntu-core/22/stable/current/ubuntu-core-22-amd64.img.xz
wget http://cdimages.ubuntu.com/ubuntu-core/22/stable/current/ubuntu-core-22-amd64.lxd.tar.xz
xz -T0 -d ubuntu-core-22-amd64.img.xz
qemu-img convert -f raw -O qcow2 ubuntu-core-22-amd64.img ubuntu-core-22-amd64.qcow2
lxc image import ubuntu-core-22-amd64.lxd.tar.xz ubuntu-core-22-amd64.qcow2 --alias core22