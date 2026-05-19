variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "address_space" {
  type = list(string)
  validation {
    condition     = length(var.address_space) > 0
    error_message = "address_space must not be empty."
  }
}
variable "subnets" {
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegations = optional(list(object({
      name    = string
      service = string
      actions = optional(list(string), ["Microsoft.Network/virtualNetworks/subnets/action"])
    })), [])
    nsg_name         = optional(string)
    route_table_name = optional(string)
  }))
}
variable "dns_servers" { type = list(string) default = null }
variable "tags" { type = map(string) default = {} }
variable "nsg_rules" {
  type = map(list(object({
    name = string
    priority = number
    direction = string
    access = string
    protocol = string
    source_port_range = string
    destination_port_range = string
    source_address_prefix = string
    destination_address_prefix = string
  })))
  default = {}
}
variable "route_tables" { type = map(list(object({ name = string, address_prefix = string, next_hop_type = string }))) default = {} }
variable "private_dns_links" { type = map(string) default = {} }
variable "enable_ddos" { type = bool default = false }
