variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "address_space" { type = list(string) }
variable "dns_servers" { type = list(string) default = null }
variable "tags" { type = map(string) default = {} }
variable "ddos_protection" { type = object({ id = string, enable = bool }) default = null }
variable "subnets" {
  type = map(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    create_nsg        = optional(bool, false)
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
    delegations = optional(list(object({ name = string, service = string, actions = list(string) })), [])
  }))
}
