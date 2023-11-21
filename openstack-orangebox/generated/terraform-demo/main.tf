variable "cloud_admin_name" {
  description = "Username of Cloud Admin"
  default     = "admin"
}


variable "cloud_admin_password" {
  description = "Cloud Admin's password"
}


variable "cloud_admin_project" {
  description = "Default project for Cloud Admin"
  default     = "admin"
}


variable "cloud_admin_domain" {
  description = "Domain name for Cloud Admin"
  default     = "admin_domain"
}


variable "auth_url" {
  description = "Keystone endpoint URL"
}


variable "region" {
  description = "OpenStack region name"
  default     = "RegionOne"
}


variable "cacert" {
  description = "CA certificate to connect to Keystone endpoint URL"
  default     = ""
}


variable "insecure" {
  description = "Trust self-signed SSL certificates"
  default     = true
}


variable "ssh_key_path" {
  description = "Path to a SSH public key for demo"
  default     = "id_rsa.pub"
}


terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.49.0"
    }
  }
}


# Cloud Admin provider
provider "openstack" {
  user_name = var.cloud_admin_name
  password  = var.cloud_admin_password


  tenant_name = var.cloud_admin_project
  domain_name = var.cloud_admin_domain


  auth_url    = var.auth_url
  region      = var.region
  cacert_file = var.cacert
  insecure    = var.insecure
}


# --- Identity -------------------------------------------------------------------------


# Domains


resource "openstack_identity_project_v3" "administration-domain" {
  name        = "Administration"
  description = "Administration domain"
  is_domain   = true
}


resource "openstack_identity_project_v3" "engineering-domain" {
  name        = "Engineering"
  description = "Engineering domain"
  is_domain   = true
}


resource "openstack_identity_project_v3" "support-domain" {
  name        = "Support"
  description = "Support domain"
  is_domain   = true
}




# Projects


resource "openstack_identity_project_v3" "production-project" {
  name        = "Production"
  description = "Accessible by members of DevOps group"
  domain_id   = openstack_identity_project_v3.engineering-domain.id
}


resource "openstack_identity_project_v3" "staging-project" {
  name        = "Staging"
  description = "Accessible by members of DevOps and Developers groups"
  domain_id   = openstack_identity_project_v3.engineering-domain.id
}


resource "openstack_identity_project_v3" "development-project" {
  name        = "Development"
  description = "Accessible by members of Developers group"
  domain_id   = openstack_identity_project_v3.engineering-domain.id
}




# Users


resource "openstack_identity_user_v3" "alice" {
  domain_id                             = openstack_identity_project_v3.engineering-domain.id
  default_project_id                    = openstack_identity_project_v3.production-project.id
  name                                  = "Alice"
  password                              = "Alice"
  ignore_change_password_upon_first_use = true
  multi_factor_auth_enabled             = false
}


resource "openstack_identity_user_v3" "bob" {
  domain_id                             = openstack_identity_project_v3.engineering-domain.id
  default_project_id                    = openstack_identity_project_v3.staging-project.id
  name                                  = "Bob"
  password                              = "Bob"
  ignore_change_password_upon_first_use = true
  multi_factor_auth_enabled             = false
}


resource "openstack_identity_user_v3" "cindy" {
  domain_id                             = openstack_identity_project_v3.engineering-domain.id
  default_project_id                    = openstack_identity_project_v3.staging-project.id
  name                                  = "Cindy"
  password                              = "Cindy"
  ignore_change_password_upon_first_use = true
  multi_factor_auth_enabled             = false
}


resource "openstack_identity_user_v3" "dave" {
  domain_id                             = openstack_identity_project_v3.engineering-domain.id
  default_project_id                    = openstack_identity_project_v3.development-project.id
  name                                  = "Dave"
  password                              = "Dave"
  ignore_change_password_upon_first_use = true
  multi_factor_auth_enabled             = false
}


resource "openstack_identity_user_v3" "ed" {
  domain_id                             = openstack_identity_project_v3.engineering-domain.id
  default_project_id                    = openstack_identity_project_v3.development-project.id
  name                                  = "Ed"
  password                              = "Ed"
  ignore_change_password_upon_first_use = true
  multi_factor_auth_enabled             = false
}




# Groups


resource "openstack_identity_group_v3" "domain-admins-group" {
  name        = "Domain Admins"
  description = "Domain Admins group"
  domain_id   = openstack_identity_project_v3.engineering-domain.id
}


resource "openstack_identity_group_v3" "admins-group" {
  name        = "Admins"
  description = "Admins group"
  domain_id   = openstack_identity_project_v3.engineering-domain.id
}


resource "openstack_identity_group_v3" "devops-group" {
  name        = "DevOps"
  description = "DevOps group"
  domain_id   = openstack_identity_project_v3.engineering-domain.id
}


resource "openstack_identity_group_v3" "developers-group" {
  name        = "Developers"
  description = "Developers group"
  domain_id   = openstack_identity_project_v3.engineering-domain.id
}




# User memberships


resource "openstack_identity_user_membership_v3" "alice-domain-admins" {
  user_id  = openstack_identity_user_v3.alice.id
  group_id = openstack_identity_group_v3.domain-admins-group.id
}


resource "openstack_identity_user_membership_v3" "alice-admins" {
  user_id  = openstack_identity_user_v3.alice.id
  group_id = openstack_identity_group_v3.admins-group.id
}


resource "openstack_identity_user_membership_v3" "bob-devops" {
  user_id  = openstack_identity_user_v3.bob.id
  group_id = openstack_identity_group_v3.devops-group.id
}


resource "openstack_identity_user_membership_v3" "cindy-devops" {
  user_id  = openstack_identity_user_v3.cindy.id
  group_id = openstack_identity_group_v3.devops-group.id
}


resource "openstack_identity_user_membership_v3" "dave-developers" {
  user_id  = openstack_identity_user_v3.dave.id
  group_id = openstack_identity_group_v3.developers-group.id
}


resource "openstack_identity_user_membership_v3" "ed-developers" {
  user_id  = openstack_identity_user_v3.ed.id
  group_id = openstack_identity_group_v3.developers-group.id
}




# Roles


data "openstack_identity_role_v3" "admin-role" {
  name = "Admin"
}


data "openstack_identity_role_v3" "member-role" {
  name = "member"
}


data "openstack_identity_role_v3" "reader-role" {
  name = "reader"
}


data "openstack_identity_role_v3" "load-balancer-admin-role" {
  name = "load-balancer_admin"
}




# Role assignments


resource "openstack_identity_role_assignment_v3" "engineering-domain-admins-admin" {
  domain_id = openstack_identity_project_v3.engineering-domain.id
  group_id  = openstack_identity_group_v3.domain-admins-group.id
  role_id   = data.openstack_identity_role_v3.admin-role.id
}


resource "openstack_identity_role_assignment_v3" "production-admins-admin" {
  project_id = openstack_identity_project_v3.production-project.id
  group_id   = openstack_identity_group_v3.admins-group.id
  role_id    = data.openstack_identity_role_v3.admin-role.id
}


resource "openstack_identity_role_assignment_v3" "production-admins-load-balancer-admin" {
  project_id = openstack_identity_project_v3.production-project.id
  group_id   = openstack_identity_group_v3.admins-group.id
  role_id    = data.openstack_identity_role_v3.load-balancer-admin-role.id
}


resource "openstack_identity_role_assignment_v3" "production-devops-member" {
  project_id = openstack_identity_project_v3.production-project.id
  group_id   = openstack_identity_group_v3.devops-group.id
  role_id    = data.openstack_identity_role_v3.member-role.id
}


resource "openstack_identity_role_assignment_v3" "staging-admins-admin" {
  project_id = openstack_identity_project_v3.staging-project.id
  group_id   = openstack_identity_group_v3.admins-group.id
  role_id    = data.openstack_identity_role_v3.admin-role.id
}


resource "openstack_identity_role_assignment_v3" "staging-devops-member" {
  project_id = openstack_identity_project_v3.staging-project.id
  group_id   = openstack_identity_group_v3.devops-group.id
  role_id    = data.openstack_identity_role_v3.member-role.id
}


resource "openstack_identity_role_assignment_v3" "staging-developers-reader" {
  project_id = openstack_identity_project_v3.staging-project.id
  group_id   = openstack_identity_group_v3.developers-group.id
  role_id    = data.openstack_identity_role_v3.reader-role.id
}


resource "openstack_identity_role_assignment_v3" "development-admins-admin" {
  project_id = openstack_identity_project_v3.development-project.id
  group_id   = openstack_identity_group_v3.admins-group.id
  role_id    = data.openstack_identity_role_v3.admin-role.id
}


resource "openstack_identity_role_assignment_v3" "development-devops-reader" {
  project_id = openstack_identity_project_v3.development-project.id
  group_id   = openstack_identity_group_v3.devops-group.id
  role_id    = data.openstack_identity_role_v3.reader-role.id
}


resource "openstack_identity_role_assignment_v3" "development-developers-member" {
  project_id = openstack_identity_project_v3.development-project.id
  group_id   = openstack_identity_group_v3.developers-group.id
  role_id    = data.openstack_identity_role_v3.member-role.id
}




# Terraform provider specific to the user


# Alice provider
#provider "openstack" {
#  alias     = "alice"
#  user_name = openstack_identity_user_v3.alice.name
  password  = openstack_identity_user_v3.alice.password


  tenant_name = openstack_identity_project_v3.production-project.name
  domain_name = openstack_identity_project_v3.engineering-domain.name


  auth_url    = var.auth_url
  region      = var.region
  cacert_file = var.cacert
  insecure    = var.insecure
#}

provider "openstack" {
  alias     = "alice"
  user_name = "Alice"
  password  = "Alice"


  tenant_name = "Production"
  domain_name = "Engineering"


  auth_url    = "https://172.27.25.180:5000/v3"
  region      = "RegionOne"
  cacert_file = var.cacert
  insecure    = var.insecure
}





# --- Networking -----------------------------------------------------------------------


# Provider network


data "openstack_networking_network_v2" "ext-net" {
  name = "ext-net"
}




# Project networks


resource "openstack_networking_network_v2" "frontend-network" {
  name           = "Frontend"
  admin_state_up = "true"
  tenant_id      = openstack_identity_project_v3.production-project.id
}


resource "openstack_networking_subnet_v2" "frontend-subnet" {
  network_id = openstack_networking_network_v2.frontend-network.id
  cidr       = "192.168.10.0/24"
  allocation_pool {
    start = "192.168.10.10"
    end   = "192.168.10.254"
  }
  tenant_id = openstack_identity_project_v3.production-project.id
}


resource "openstack_networking_subnet_route_v2" "frontend-subnet-route" {
  subnet_id        = openstack_networking_subnet_v2.frontend-subnet.id
  destination_cidr = "192.168.20.0/24"
  next_hop         = "192.168.10.2"
}


# Port used as the interface to the Internal Router
resource "openstack_networking_port_v2" "frontend-port" {
  name           = "frontend-port"
  network_id     = openstack_networking_network_v2.frontend-network.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.frontend-subnet.id
    ip_address = "192.168.10.2"
  }
}


resource "openstack_networking_network_v2" "backend-network" {
  name           = "Backend"
  admin_state_up = "true"
  tenant_id      = openstack_identity_project_v3.production-project.id
}


resource "openstack_networking_subnet_v2" "backend-subnet" {
  network_id = openstack_networking_network_v2.backend-network.id
  cidr       = "192.168.20.0/24"
  allocation_pool {
    start = "192.168.20.10"
    end   = "192.168.20.254"
  }
  tenant_id = openstack_identity_project_v3.production-project.id
}




# Internal router


resource "openstack_networking_router_v2" "internal-router" {
  name           = "Internal Router"
  admin_state_up = true
  tenant_id      = openstack_identity_project_v3.production-project.id
}


resource "openstack_networking_router_interface_v2" "internal-router-frontend-interface" {
  router_id = openstack_networking_router_v2.internal-router.id
  port_id   = openstack_networking_port_v2.frontend-port.id
}


resource "openstack_networking_router_interface_v2" "internal-router-backend-interface" {
  router_id = openstack_networking_router_v2.internal-router.id
  subnet_id = openstack_networking_subnet_v2.backend-subnet.id
}




# External router


resource "openstack_networking_router_v2" "ext-net-router" {
  name                = "External Router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.ext-net.id
  tenant_id           = openstack_identity_project_v3.production-project.id
}


resource "openstack_networking_router_interface_v2" "ext-net-router-frontend-interface" {
  router_id = openstack_networking_router_v2.ext-net-router.id
  subnet_id = openstack_networking_subnet_v2.frontend-subnet.id
}




# Security groups


resource "openstack_networking_secgroup_v2" "jumphost-servers-secgroup" {
  name        = "Jumphost servers"
  description = "Security group allowing traffic to Jumphost servers"
  tenant_id   = openstack_identity_project_v3.production-project.id
}


resource "openstack_networking_secgroup_v2" "backend-servers-secgroup" {
  name        = "Backend servers"
  description = "Security group allowing traffic to Backend servers"
  tenant_id   = openstack_identity_project_v3.production-project.id
}


resource "openstack_networking_secgroup_v2" "frontend-servers-secgroup" {
  name        = "Frontend servers"
  description = "Security group allowing traffic to Frontend servers"
  tenant_id   = openstack_identity_project_v3.production-project.id
}




# Security group rules


resource "openstack_networking_secgroup_rule_v2" "jumphost-servers-secgroup-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.jumphost-servers-secgroup.id
}


resource "openstack_networking_secgroup_rule_v2" "frontend-servers-secgroup-rule-1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.frontend-servers-secgroup.id
}


resource "openstack_networking_secgroup_rule_v2" "frontend-servers-secgroup-rule-2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.frontend-servers-secgroup.id
  remote_group_id   = openstack_networking_secgroup_v2.jumphost-servers-secgroup.id
}


resource "openstack_networking_secgroup_rule_v2" "backend-servers-secgroup-rule" {
  security_group_id = openstack_networking_secgroup_v2.backend-servers-secgroup.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = openstack_networking_secgroup_v2.frontend-servers-secgroup.id
}


# --- Storage --------------------------------------------------------------------------


# Volumes


resource "openstack_blockstorage_volume_v3" "db-1-volume" {
  provider = openstack.alice
  name     = "db-1-volume"
  size     = 1
}


resource "openstack_blockstorage_volume_v3" "db-2-volume" {
  provider = openstack.alice
  name     = "db-2-volume"
  size     = 1
}









# --- Compute --------------------------------------------------------------------------


# Server groups


resource "openstack_compute_servergroup_v2" "frontend-servers" {
  provider = openstack.alice
  name     = "Frontend Servers"
  policies = ["soft-anti-affinity"]
}


resource "openstack_compute_servergroup_v2" "backend-servers" {
  provider = openstack.alice
  name     = "Backend Servers"
  policies = ["soft-anti-affinity"]
}




# Availability Zones


resource "openstack_compute_aggregate_v2" "az-1" {
  name = "az-1"
  zone = "az-1"
  hosts = [
    "node01.maas",
    "node02.maas",
  ]
}


resource "openstack_compute_aggregate_v2" "az-2" {
  name = "az-2"
  zone = "az-2"
  hosts = [
    "node03.maas",
    "node05.maas",
  ]
}


resource "openstack_compute_aggregate_v2" "az-3" {
  name = "az-3"
  zone = "az-3"
  hosts = [
    "node06.maas",
    "node07.maas",
  ]
}


# Resources created by Alice in project Production, domain Engineering


# Images


resource "openstack_images_image_v2" "ubuntu-jammy" {
  provider         = openstack.alice
  name             = "Ubuntu Server 22.04 (Jammy Jellyfish)"
  image_source_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format      = "qcow2"


  properties = {
    key = "value"
  }
}




# Key pair


data "local_file" "alice-public-key" {
  filename = var.ssh_key_path
}


resource "openstack_compute_keypair_v2" "alice-keypair" {
  name       = "alice-keypair"
  user_id    = openstack_identity_user_v3.alice.id
  public_key = data.local_file.alice-public-key.content
}




# Servers


resource "openstack_compute_instance_v2" "jumphost" {
  provider = openstack.alice


  name        = "jumphost"
  image_id    = openstack_images_image_v2.ubuntu-jammy.id
  flavor_name = "m1.small"
  key_pair    = openstack_compute_keypair_v2.alice-keypair.name


  security_groups = ["${openstack_networking_secgroup_v2.jumphost-servers-secgroup.name}"]


  scheduler_hints {
    group = openstack_compute_servergroup_v2.frontend-servers.id
  }


  network {
    name = openstack_networking_network_v2.frontend-network.name
  }
}


resource "openstack_compute_instance_v2" "web-1" {
  provider = openstack.alice


  name        = "web-1"
  image_id    = openstack_images_image_v2.ubuntu-jammy.id
  flavor_name = "m1.small"
  key_pair    = openstack_compute_keypair_v2.alice-keypair.name


  security_groups = ["${openstack_networking_secgroup_v2.frontend-servers-secgroup.name}"]


  scheduler_hints {
    group = openstack_compute_servergroup_v2.frontend-servers.id
  }


  network {
    name = openstack_networking_network_v2.frontend-network.name
  }
}


resource "openstack_compute_instance_v2" "web-2" {
  provider = openstack.alice


  name        = "web-2"
  image_id    = openstack_images_image_v2.ubuntu-jammy.id
  flavor_name = "m1.small"
  key_pair    = openstack_compute_keypair_v2.alice-keypair.name


  security_groups = ["${openstack_networking_secgroup_v2.frontend-servers-secgroup.name}"]


  scheduler_hints {
    group = openstack_compute_servergroup_v2.frontend-servers.id
  }


  network {
    name = openstack_networking_network_v2.frontend-network.name
  }
}


resource "openstack_compute_instance_v2" "db-1" {
  provider = openstack.alice


  name        = "db-1"
  image_id    = openstack_images_image_v2.ubuntu-jammy.id
  flavor_name = "m1.small"
  key_pair    = openstack_compute_keypair_v2.alice-keypair.name


  security_groups = ["${openstack_networking_secgroup_v2.backend-servers-secgroup.name}"]


  scheduler_hints {
    group = openstack_compute_servergroup_v2.backend-servers.id
  }


  network {
    name = openstack_networking_network_v2.backend-network.name
  }
}


resource "openstack_compute_instance_v2" "db-2" {
  provider = openstack.alice


  name        = "db-2"
  image_id    = openstack_images_image_v2.ubuntu-jammy.id
  flavor_name = "m1.small"
  key_pair    = openstack_compute_keypair_v2.alice-keypair.name


  security_groups = ["${openstack_networking_secgroup_v2.backend-servers-secgroup.name}"]


  scheduler_hints {
    group = openstack_compute_servergroup_v2.backend-servers.id
  }


  network {
    name = openstack_networking_network_v2.backend-network.name
  }
}




# Floating IP for jumphost server


resource "openstack_networking_floatingip_v2" "jumphost-floating-ip" {
  provider = openstack.alice
  pool     = data.openstack_networking_network_v2.ext-net.name
}


resource "openstack_compute_floatingip_associate_v2" "jumphost-floating-ip-associate" {
  floating_ip = openstack_networking_floatingip_v2.jumphost-floating-ip.address
  instance_id = openstack_compute_instance_v2.jumphost.id
}




# Volume attachments


resource "openstack_compute_volume_attach_v2" "db-1-volume-attachment" {
  instance_id = openstack_compute_instance_v2.db-1.id
  volume_id   = openstack_blockstorage_volume_v3.db-1-volume.id
}


resource "openstack_compute_volume_attach_v2" "db-2-volume-attachment" {
  instance_id = openstack_compute_instance_v2.db-2.id
  volume_id   = openstack_blockstorage_volume_v3.db-2-volume.id
}








# --- Load Balancer --------------------------------------------------------------------


resource "openstack_lb_loadbalancer_v2" "web-loadbalancer" {
  provider      = openstack.alice
  name          = "Web"
  vip_subnet_id = openstack_networking_subnet_v2.frontend-subnet.id
}


resource "openstack_lb_listener_v2" "web-listener" {
  provider        = openstack.alice
  name            = "Web HTTP Listener"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.web-loadbalancer.id


  insert_headers = {
    X-Forwarded-For = "true"
  }
}


resource "openstack_lb_pool_v2" "web-pool" {
  provider    = openstack.alice
  name        = "Web Pool"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.web-listener.id
}


resource "openstack_lb_monitor_v2" "web-1-monitor" {
  provider    = openstack.alice
  name        = "Web Health Monitor"
  pool_id     = openstack_lb_pool_v2.web-pool.id
  type        = "HTTP"
  delay       = 20
  timeout     = 10
  max_retries = 5
}


resource "openstack_lb_member_v2" "web-1-member" {
  provider      = openstack.alice
  address       = openstack_compute_instance_v2.web-1.access_ip_v4
  protocol_port = 80
  pool_id       = openstack_lb_pool_v2.web-pool.id
  subnet_id     = openstack_networking_subnet_v2.frontend-subnet.id
}


resource "openstack_lb_member_v2" "web-2-member" {
  provider      = openstack.alice
  address       = openstack_compute_instance_v2.web-2.access_ip_v4
  protocol_port = 80
  pool_id       = openstack_lb_pool_v2.web-pool.id
  subnet_id     = openstack_networking_subnet_v2.frontend-subnet.id
}


resource "openstack_networking_floatingip_v2" "web-loadbalancer-floating-ip" {
  provider = openstack.alice
  pool     = data.openstack_networking_network_v2.ext-net.name
}


resource "openstack_networking_floatingip_associate_v2" "web-loadbalancer-floating-ip-associate" {
  floating_ip = openstack_networking_floatingip_v2.web-loadbalancer-floating-ip.address
  port_id     = openstack_lb_loadbalancer_v2.web-loadbalancer.vip_port_id
}




# --- DNS ------------------------------------------------------------------------------


resource "openstack_dns_zone_v2" "example-zone" {
  provider    = openstack.alice
  name        = "example.com."
  email       = "jdoe@example.com"
  description = "An example zone"
  ttl         = 3000
  type        = "PRIMARY"
}


resource "openstack_dns_recordset_v2" "recordset-example-zone" {
  provider    = openstack.alice
  zone_id     = openstack_dns_zone_v2.example-zone.id
  name        = "www.example.com."
  description = "DNS A record pointing to Web Loadbalancer"
  ttl         = 3000
  type        = "A"
  records = [
    "${openstack_networking_floatingip_v2.web-loadbalancer-floating-ip.address}"
  ]
}




# --- Object Storage -------------------------------------------------------------------


resource "openstack_objectstorage_container_v1" "container" {
  provider       = openstack.alice
  name           = "container-1"
  container_read = ".r:*,.rlistings"
}


resource "openstack_objectstorage_object_v1" "object" {
  provider       = openstack.alice
  count          = 10
  container_name = openstack_objectstorage_container_v1.container.name
  name           = "test-${count.index}.json"


  content_type = "application/json"
  content      = <<-JSON
    {
      "foo" : "bar"
    }
  JSON
}
