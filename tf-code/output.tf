output "vm_ips" {
  value = {
    for vm in libvirt_domain.k8s-nodes : vm.name => vm.network_interface[0].addresses[0]
  }
}
