variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/opt/kvm/pool1"
}

variable "kubernetes-hosts" {
  type = map(object({
    memory = number
    vcpu   = number
  }))
  default = {
    "master-server" = { memory = 4096, vcpu = 2 }
    "node1"         = { memory = 4096, vcpu = 2 }
    "node2"         = { memory = 4096, vcpu = 2 }
    "node3"         = { memory = 4096, vcpu = 2 }
  }
}
