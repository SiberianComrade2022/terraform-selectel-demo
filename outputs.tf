output "bastion_linux_image" {
  value = data.openstack_images_image_v2.bastion_linux_image.name
}

output "pool_members" {
  value = formatlist("%v %v", openstack_compute_instance_v2.tf_linux_pool.*.name, openstack_compute_instance_v2.tf_linux_pool.*.network.0.fixed_ip_v4)
}

output "prometheus_ip" {
  description = "Private IP address of Prometheus instance"
  value       = openstack_compute_instance_v2.prom_server.access_ip_v4
}

output "prometheus_public_ip" {
  description = "Public IP address of Prometheus instance"
  value       = openstack_networking_floatingip_v2.ext_float_ip_prom.address
}

output "bastion_ip" {
  description = "Public ingress IP address of Bastion instance"
  value       = openstack_networking_floatingip_v2.ext_float_ip_bastion.address
}

output "router_egress" {
  description = "Public egress IP address for Router"
  value       = openstack_networking_router_v2.tf_router_1.external_fixed_ip[0].ip_address
}

output "inbound_access_from" {
  description = "Public IP address of my ISP"
  value       = data.external.get_isp_source_address.result.my_ip
}

output "loadbalancer_ip" {
  description = "Public IP address of Load Balancer for ingress traffic"
  value       = openstack_networking_floatingip_v2.ext_float_ip_lb.address
}

output "ssh_private_key" {
  description = "Path to SSH private key to use in 'ssh -i <this value>'"
  value       = "${path.module}/${var.ssh_private_key}"
}

output "ssh_to_bastion" {
  description = "Suggested command to connect Infrastucture"
  value       = "ssh -q -o StrictHostKeyChecking=no -i ${path.module}/${var.ssh_private_key} root@${openstack_networking_floatingip_v2.ext_float_ip_bastion.address}"
}

output "https_to_prometheus" {
  description = "Suggested URL to open Prometheus page"
  value       = "https://${openstack_networking_floatingip_v2.ext_float_ip_prom.address}:9090"
}
