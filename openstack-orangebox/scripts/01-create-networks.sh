#!/bin/bash

source openrc

openstack network create --external --provider-network-type flat --provider-physical-network physnet1 provider
openstack subnet create --gateway 172.27.26.1 --dhcp --subnet-range 172.27.26.0/23 --allocation-pool start=172.27.26.100,end=172.27.26.200 --ip-version 4 --dns-nameserver 172.27.26.1 --network provider prov-sub
#openstack port create --no-security-group --network provider --fixed-ip ip-address=172.16.8.199 provider
#openstack port create --no-security-group --network provider --fixed-ip ip-address=172.16.8.200 provider

openstack network create --internal ubuntu-net
openstack subnet create --gateway 192.168.0.1 --dhcp --subnet-range 192.168.0.0/24 --allocation-pool start=192.168.0.2,end=192.168.0.254 --network ubuntu-net ubuntu-subnet

openstack router create prov-net-router 
openstack router add subnet prov-net-router ubuntu-subnet
openstack router set prov-net-router --external-gateway prov-net --enable-snat