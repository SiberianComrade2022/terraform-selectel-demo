# ansible all -i inventory --list-hosts
# openstack-inventory --list

resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/ansible/inventory"
  file_permission = "0644"
  content = templatefile(
    "${path.module}/templates/ansible-inventory.tftpl",
    {
      pool_ips    = openstack_compute_instance_v2.tf_linux_pool[*].access_ip_v4,
      bastion_ip  = openstack_networking_floatingip_v2.ext_float_ip_bastion.address
      prom_ip     = openstack_compute_instance_v2.prom_server.access_ip_v4,
      private_key = strrev(split("/", (strrev(var.ssh_private_key)))[0])
    }
  )
}

resource "local_file" "ansible_variables" {
  filename        = "${path.module}/ansible/group_vars/all.yaml"
  file_permission = "0644"
  content = templatefile(
    "${path.module}/templates/ansible-variables.tftpl",
    {
      prom_path   = var.prometheus_path,
      lb_port     = var.lb_components["listener_protocol_port"],
      private_key = strrev(split("/", (strrev(var.ssh_private_key)))[0])
    }
  )
}

resource "local_file" "ansible_cfg" {
  filename        = "${path.module}/ansible/ansible.cfg"
  file_permission = "0644"
  content = templatefile(
    "${path.module}/templates/ansible-cfg.tftpl",
    {
      private_key = strrev(split("/", (strrev(var.ssh_private_key)))[0])
    }
  )
}
