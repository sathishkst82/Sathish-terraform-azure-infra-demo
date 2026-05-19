variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "subnet_id" { type = string }
variable "vms" {
  type = map(object({
    size              = string
    admin_username    = string
    admin_password    = string
    enable_public_ip  = optional(bool, false)
  }))
}
variable "tags" { type = map(string) default = {} }
