resource "azurerm_network_interface" "this" {
  for_each            = var.vms
  name                = "nic-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(each.value.enable_public_ip, false) ? azurerm_public_ip.this[each.key].id : null
  }
}

resource "azurerm_public_ip" "this" {
  for_each            = { for k, v in var.vms : k => v if try(v.enable_public_ip, false) }
  name                = "pip-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_windows_virtual_machine" "this" {
  for_each            = var.vms
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  network_interface_ids = [azurerm_network_interface.this[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  identity { type = "SystemAssigned" }
  tags = var.tags
}
