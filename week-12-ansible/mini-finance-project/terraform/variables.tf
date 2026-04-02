variable "admin_username" {
  default = "azureuser"
}

variable "location" {
  default = "South Africa North"
}

variable "vm_name" {
  default = "mini-finance-vm"
}

variable "resource_group_name" {
  default = "mini-finance-rg"
}

variable "ssh_public_key" {
  description = "Path to your SSH Public Key"
  default     = "~/.ssh/id_ed25519.pub"
}