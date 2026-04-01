# output "public_ip_addresses_by_vm" {
#   description = "Map of VM index to public IP addresses."
#   value = {
#     for idx, ip in azurerm_public_ip.public_ip :
#     "web-${idx}" => ip.ip_address
#   }
# }

# output "private_ip_addresses_by_vm" {
#   description = "Map of VM index to private IP addresses."
#   value = {
#     for idx, nic in azurerm_network_interface.private_nic :
#     "app-${idx}" => nic.private_ip_address
#   }
# }

# output "ssh_commands_by_vm" {
#   description = "SSH commands for VMs with public IPs."
#   value = {
#     for idx, ip in azurerm_public_ip.public_ip :
#     "web-${idx}" => "ssh ${var.admin_username}@${ip.ip_address}"
#   }
# }


output "web_vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "web_vm_private_ip" {
  value = azurerm_network_interface.public_nic.private_ip_address
}

output "app_vm_private_ip" {
  value = azurerm_network_interface.private_nic.private_ip_address
}

output "web_ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.public_ip.ip_address}"
}