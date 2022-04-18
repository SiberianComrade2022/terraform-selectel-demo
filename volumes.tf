# Verify: openstack volume list

resource "openstack_blockstorage_volume_v3" "bastion_volume_1" {
  name                 = "bastion-volume-1"
  size                 = "5"
  image_id             = data.openstack_images_image_v2.bastion_linux_image.id
  volume_type          = var.volume_type
  availability_zone    = var.server_zone
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_blockstorage_volume_v3" "prom_volume_1" {
  name                 = "prom-volume-1"
  size                 = "5"
  image_id             = data.openstack_images_image_v2.prom_linux_image.id
  volume_type          = var.volume_type
  availability_zone    = var.server_zone
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_blockstorage_volume_v3" "pool_volume" {

  count = var.replicas_count

  name                 = "pool-volume-1-${count.index + 1}"
  size                 = "5"
  image_id             = data.openstack_images_image_v2.pool_linux_image.id
  volume_type          = var.volume_type
  availability_zone    = var.server_zone
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}
