resource "libvirt_volume" "ubuntu-qcow2" {
  for_each = var.kubernetes-hosts
  name     = each.key
  # "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  # https://github.com/dmacvicar/terraform-provider-libvirt/issues/357#issuecomment-412887139
  source = "/home/lucian/Downloads/ubuntu-22.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

data "template_file" "user_data" {
  for_each = var.kubernetes-hosts
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = each.key
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each       = var.kubernetes-hosts
  name           = "${each.key}-init.iso"
  user_data      = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config.rendered
}

resource "libvirt_domain" "k8s-nodes" {
  for_each = var.kubernetes-hosts
  name     = each.key
  memory   = each.value.memory
  vcpu     = each.value.vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
    hostname       = each.key
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.ubuntu-qcow2[each.key].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
