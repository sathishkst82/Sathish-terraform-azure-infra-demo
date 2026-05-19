locals {
  nsg_enabled_subnets = { for k, v in var.subnets : k => v if try(v.create_nsg, false) }
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection == null ? [] : [var.ddos_protection]
    content {
      id     = ddos_protection_plan.value.id
      enable = ddos_protection_plan.value.enable
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags["LastReviewed"]]
  }
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  service_endpoints = try(each.value.service_endpoints, null)

  dynamic "delegation" {
    for_each = try(each.value.delegations, [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each            = local.nsg_enabled_subnets
  name                = "nsg-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = try(each.value.nsg_rules, [])
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  lifecycle { create_before_destroy = true }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = local.nsg_enabled_subnets
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
  depends_on                = [azurerm_subnet.this, azurerm_network_security_group.this]
}
