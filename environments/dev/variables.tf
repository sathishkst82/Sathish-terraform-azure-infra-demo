variable "project" { type = string default = "opella" }
variable "owner" { type = string default = "platform-team" }
variable "cost_center" { type = string default = "CC1001" }
variable "vm_admin_username" { type = string default = "azureadmin" }
variable "vm_admin_password" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.vm_admin_password) >= 12
    error_message = "vm_admin_password must be at least 12 characters."
  }
}
