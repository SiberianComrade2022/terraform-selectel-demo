resource "openstack_lb_loadbalancer_v2" "lb" {
  name   = var.lb_sngl_name
  region = var.region

  # Internal (private) subnet with pool members
  vip_subnet_id = openstack_networking_subnet_v2.tf_subnet_1.id

  # Type of Load balancer: Single, Active/Passive
  flavor_id = var.lb_sngl_flavor_uuid
}

resource "openstack_lb_listener_v2" "lb_listener" {
  name            = "LB-Listener"
  protocol        = var.lb_components["listener_protocol"]
  protocol_port   = var.lb_components["listener_protocol_port"]
  loadbalancer_id = openstack_lb_loadbalancer_v2.lb.id
}

resource "openstack_lb_pool_v2" "lb_pool" {
  name        = "LB-Pool"
  protocol    = var.lb_components["pool_protocol"]
  lb_method   = var.lb_components["pool_lb_method"]
  listener_id = openstack_lb_listener_v2.lb_listener.id
}

resource "openstack_lb_monitor_v2" "monitor" {
  name        = "LB-Monitor"
  pool_id     = openstack_lb_pool_v2.lb_pool.id
  type        = var.lb_components["monitor_type"]
  delay       = var.lb_components["monitor_delay"]
  timeout     = var.lb_components["monitor_timeout"]
  max_retries = var.lb_components["monitor_retries"]
}

resource "openstack_lb_members_v2" "member" {
  pool_id = openstack_lb_pool_v2.lb_pool.id

  dynamic "member" {
    #for_each = var.server_access_ips
    for_each = openstack_compute_instance_v2.tf_linux_pool[*].access_ip_v4
    content {
      name           = "Pool Member"
      subnet_id      = openstack_networking_subnet_v2.tf_subnet_1.id
      address        = member.value
      protocol_port  = var.lb_components["member_protocol_port"]
      weight         = 1
      backup         = false
      admin_state_up = true
    }
  }
}
