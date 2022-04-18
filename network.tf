resource "openstack_networking_floatingip_v2" "ext_float_ip_bastion" {
  pool = "external-network"
}

# Associating External floating IP to Bastion server
resource "openstack_compute_floatingip_associate_v2" "float_ip_bastion_assoc" {
  depends_on = [
    openstack_networking_network_v2.tf_network_1
  ]
  floating_ip = openstack_networking_floatingip_v2.ext_float_ip_bastion.address
  instance_id = openstack_compute_instance_v2.linux_bastion.id
}

resource "openstack_networking_floatingip_v2" "ext_float_ip_prom" {
  pool = "external-network"
}

# Associating External floating IP to Prometheus server
resource "openstack_compute_floatingip_associate_v2" "float_ip_prom_assoc" {
  depends_on = [
    openstack_networking_network_v2.tf_network_1
  ]
  floating_ip = openstack_networking_floatingip_v2.ext_float_ip_prom.address
  instance_id = openstack_compute_instance_v2.prom_server.id
}

resource "openstack_networking_floatingip_v2" "ext_float_ip_lb" {
  pool = "external-network"
}

# Associating External floating IP to LB web
resource "openstack_networking_floatingip_associate_v2" "float_ip_lb_assoc" {
  floating_ip = openstack_networking_floatingip_v2.ext_float_ip_lb.address
  port_id     = openstack_lb_loadbalancer_v2.lb.vip_port_id
}

# Verify: openstack router list, openstack router show tf_router_1
resource "openstack_networking_router_v2" "tf_router_1" {
  name                = var.router_name
  external_network_id = data.openstack_networking_network_v2.external_net.id
  admin_state_up      = true
}

# Verify: openstack network list
resource "openstack_networking_network_v2" "tf_network_1" {
  name     = var.network_name
  external = false
}

# Verify: openstack subnet list, openstack subnet show <name>
resource "openstack_networking_subnet_v2" "tf_subnet_1" {
  network_id = openstack_networking_network_v2.tf_network_1.id
  #  dns_nameservers = var.dns_nameservers
  name       = var.subnet_cidr
  cidr       = var.subnet_cidr
  no_gateway = false
}

resource "openstack_networking_port_v2" "tf_bastion_port_1" {
  name       = "${var.bastion_name}-eth0"
  network_id = openstack_networking_network_v2.tf_network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.tf_subnet_1.id
  }
}

resource "openstack_networking_port_v2" "tf_linux_pool_port" {
  count      = var.replicas_count
  name       = "${var.pool_prefix}-${count.index + 1}-eth0"
  network_id = openstack_networking_network_v2.tf_network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.tf_subnet_1.id
  }
}

# Attach router to private subnet
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.tf_router_1.id
  subnet_id = openstack_networking_subnet_v2.tf_subnet_1.id
}
