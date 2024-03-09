output "VM_ACCESS_IP" {
  value = format("http://%s", azurerm_public_ip.public_ip["pip-vm_access"].ip_address)
}