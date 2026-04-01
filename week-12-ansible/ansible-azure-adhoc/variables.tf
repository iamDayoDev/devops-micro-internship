variable "name_prefix" {
  description = "Prefix used for all Azure resource names."
  type        = string
  default     = "ansible-lab"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
  default     = "rg-ansible-lab"
}

variable "location" {
  description = "Azure region where the infrastructure will be deployed."
  type        = string
  default     = "South Africa North"
}

variable "vm_roles" {
  description = "Roles used to provision the Azure virtual machines."
  type        = list(string)
  default     = ["web1", "web2", "app", "db"]
}

variable "vm_size" {
  description = "Azure VM size for each Linux VM."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Admin username used to connect to the Linux VMs."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Path to the SSH public key used for admin access to the Linux VMs."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  }

variable "tags" {
  description = "Common tags added to all Azure resources."
  type        = map(string)
  default = {
    environment = "lab"
    project     = "ansible-lab"
  }
}
