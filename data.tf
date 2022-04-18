# Bastion
data "openstack_compute_flavor_v2" "bastion_flavor" {
  name      = var.bastion_flavor
  is_public = "true"
}

data "openstack_images_image_v2" "bastion_linux_image" {
  name        = var.linux_image_name
  visibility  = "public"
  most_recent = true
}

# Prometheus
data "openstack_compute_flavor_v2" "prom_flavor" {
  name      = var.prom_flavor
  is_public = "true"
}

data "openstack_images_image_v2" "prom_linux_image" {
  name        = var.linux_image_name
  visibility  = "public"
  most_recent = true
}

# Pool of working horses
data "openstack_compute_flavor_v2" "pool_flavor" {
  name      = var.pool_flavor
  is_public = "true"
}

data "openstack_images_image_v2" "pool_linux_image" {
  name        = var.linux_image_name
  visibility  = "public"
  most_recent = true
}

# Network
data "openstack_networking_network_v2" "external_net" {
  name     = var.external_net_name
  external = true
}

# Local ISP address
data "external" "get_isp_source_address" {
  program = ["/bin/bash", "${path.module}/scripts/get_my_ip.sh"]
}
