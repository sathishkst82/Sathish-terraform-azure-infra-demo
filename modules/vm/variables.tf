variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "boot_diagnostics_storage_uri" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vms" {
  type = map(object({
    name             = string
    size             = string
    subnet_id        = string
    enable_public_ip = optional(bool, false)
  }))
}
