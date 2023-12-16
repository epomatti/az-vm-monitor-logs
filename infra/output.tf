output "ssh_command" {
  value = "ssh ${module.vm.admin_username}@${module.vm.public_ip_address}"
}
