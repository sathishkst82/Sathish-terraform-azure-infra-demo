output "resource_group_name" { value = azurerm_resource_group.this.name }
output "vnet_id" { value = module.vnet.vnet_id }
output "vm_private_ips" { value = module.vm.private_ips }
