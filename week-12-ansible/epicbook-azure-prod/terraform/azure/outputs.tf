output "public_ip_address" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "epicbook_db_endpoint" {
  value = azurerm_mysql_flexible_server.epicbook_db.fqdn
}