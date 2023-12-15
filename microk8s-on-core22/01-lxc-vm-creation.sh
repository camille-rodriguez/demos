for f in $(seq 1 3); do
  lxc init core22 --vm -d root,size=10GiB microk8s-$f
  lxc config set microk8s-$f limits.memory=8GB
  lxc config set microk8s-$f limits.cpu=4 
  lxc config set microk8s-$f security.secureboot=true 
  lxc storage volume create default microk8s-$f-ceph size=8GiB  --type block
  lxc storage volume attach default microk8s-$f-ceph microk8s-$f
  lxc config device add microk8s-$f tpm tpm path=/dev/tpm0
  lxc start microk8s-$f
done