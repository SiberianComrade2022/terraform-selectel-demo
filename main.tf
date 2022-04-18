# Verify: openstack server list, openstack server show <name>
resource "openstack_compute_instance_v2" "linux_bastion" {
  name      = var.bastion_name
  image_id  = data.openstack_images_image_v2.bastion_linux_image.id
  flavor_id = data.openstack_compute_flavor_v2.bastion_flavor.id
  # key_pair          = var.keypair_name
  key_pair          = openstack_compute_keypair_v2.infra_keypair.name
  availability_zone = var.server_zone
  user_data = templatefile(
    "${path.module}/templates/bastion-cloud-config.tftpl",
    {
      infra_private_key = indent(6, openstack_compute_keypair_v2.infra_keypair.private_key),
      master_ip         = data.external.get_isp_source_address.result.my_ip,
      proctor_ip        = var.proctor_ip,
    }
  )

  metadata = {
    role = "bastion"
  }

  network {
    port = openstack_networking_port_v2.tf_bastion_port_1.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.bastion_volume_1.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  lifecycle {
    ignore_changes = [image_id]
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

# Verify: openstack server list, openstack server show <name>
resource "openstack_compute_instance_v2" "tf_linux_pool" {

  count = var.replicas_count

  name      = "${var.pool_prefix}-${count.index + 1}"
  image_id  = data.openstack_images_image_v2.pool_linux_image.id
  flavor_id = data.openstack_compute_flavor_v2.pool_flavor.id
  # key_pair          = var.keypair_name
  key_pair          = openstack_compute_keypair_v2.infra_keypair.name
  availability_zone = var.server_zone
  user_data = templatefile(
    "${path.module}/templates/pool-cloud-config.tftpl",
    {
      version   = var.node_exporter_version,
      prom_path = var.prometheus_path,
      # hostname  = "${var.pool_prefix}-${count.index + 1}",
      prom_cert = indent(6, tls_self_signed_cert.node_x_self_signed_cert.cert_pem),
      prom_key  = indent(6, tls_private_key.infra_private_key.private_key_pem),
    }
  )

  metadata = {
    role = "pool"
  }
  network {
    port = openstack_networking_port_v2.tf_linux_pool_port[count.index].id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.pool_volume[count.index].id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  lifecycle {
    ignore_changes = [image_id]
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

# Verify: openstack server list, openstack server show <name>
resource "openstack_compute_instance_v2" "prom_server" {
  depends_on = [
    openstack_compute_instance_v2.tf_linux_pool
  ]
  name      = var.prometheus_name
  image_id  = data.openstack_images_image_v2.prom_linux_image.id
  flavor_id = data.openstack_compute_flavor_v2.prom_flavor.id
  # key_pair          = var.keypair_name
  key_pair          = openstack_compute_keypair_v2.infra_keypair.name
  availability_zone = var.server_zone

  user_data = templatefile(
    "${path.module}/templates/prom-cloud-config.tftpl",
    {
      version     = var.prometheus_version,
      prom_path   = var.prometheus_path,
      infra_key   = indent(6, tls_private_key.infra_private_key.private_key_pem),
      node_x_cert = indent(6, tls_self_signed_cert.node_x_self_signed_cert.cert_pem),
      prom_cert   = indent(6, tls_self_signed_cert.prom_self_signed_cert.cert_pem),
      pool_ips    = openstack_networking_port_v2.tf_linux_pool_port.*.all_fixed_ips.0,
      master_ip   = data.external.get_isp_source_address.result.my_ip,
      proctor_ip  = var.proctor_ip,
    }
  )
  metadata = {
    role = "prometheus"
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.prom_volume_1.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  lifecycle {
    ignore_changes = [image_id]
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}
