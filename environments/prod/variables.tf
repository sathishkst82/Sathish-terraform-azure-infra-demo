variable "ssh_public_key" {
  type = string
  validation { condition = can(regex("^ssh-rsa|^ssh-ed25519", var.ssh_public_key)) error_message = "Must be a valid SSH public key." }
}
