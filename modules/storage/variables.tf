variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name_prefix" { type = string }
variable "containers" { type = set(string) }
variable "tags" { type = map(string) default = {} }
variable "enable_private_endpoint" { type = bool default = false }
