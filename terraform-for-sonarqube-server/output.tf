output "public_ip_address" {
  description = "The public IP address of the virtual machine"
  value       = azurerm_public_ip.publicip.ip_address
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}
