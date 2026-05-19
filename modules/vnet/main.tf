locals {
  subnet_nsgs   = { for k, v in var.subnets : k => v if try(v.nsg_name, null) != null }
  subnet_routes = { for k, v in var.subnets : k => v if try(v.route_table_name, null) != null }
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos ? [1] : []
    content {
      id     = null
      enable = true
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = try(each.value.service_endpoints, [])

  dynamic "delegation" {
    for_each = try(each.value.delegations, [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service
        actions = try(delegation.value.actions, [])
      }
    }
  }

  lifecycle { create_before_destroy = true }
}

resource "azurerm_network_security_group" "this" {
  for_each            = local.subnet_nsgs
  name                = each.value.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = { for pair in flatten([for nsg, rules in var.nsg_rules : [for r in rules : { key = "${nsg}-${r.name}", nsg = nsg, rule = r }]]) : pair.key => pair }

  name                        = each.value.rule.name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = each.value.rule.protocol
  source_port_range           = each.value.rule.source_port_range
  destination_port_range      = each.value.rule.destination_port_range
  source_address_prefix       = each.value.rule.source_address_prefix
  destination_address_prefix  = each.value.rule.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = each.value.nsg
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = local.subnet_nsgs
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
