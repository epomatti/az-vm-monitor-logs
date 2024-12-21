output "ssh_command" {
  value = "ssh -i .keys/temp_rsa ${var.vm_admin_username}@${module.vm.public_ip_address}"
}
