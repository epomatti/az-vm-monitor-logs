output "ssh_command" {
  value = "ssh ${var.vm_admin_username}@${module.vm.public_ip_address}"
}
