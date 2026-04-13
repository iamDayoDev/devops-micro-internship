variable "admin_username" {
  description = "Administrator username for the Linux virtual machine."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Administrator password for the Linux virtual machine. Set this securely in a tfvars file or with TF_VAR_admin_password."
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "South Africa North"
}

variable "vm_name" {
  description = "Name of the Linux virtual machine."
  type        = string
  default     = "mini-finance-vm"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
  default     = "mini-finance-rg"
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "mini-finance-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet."
  type        = string
  default     = "mini-finance-subnet"
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "nsg_name" {
  description = "Name of the network security group."
  type        = string
  default     = "mini-finance-nsg"
}

variable "public_ip_name" {
  description = "Name of the public IP resource."
  type        = string
  default     = "mini-finance-pip"
}

variable "public_ip_allocation_method" {
  description = "Allocation method for the public IP."
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "SKU for the public IP."
  type        = string
  default     = "Standard"
}

variable "nic_name" {
  description = "Name of the network interface."
  type        = string
  default     = "mini-finance-nic"
}

variable "nic_ip_configuration_name" {
  description = "Name of the NIC IP configuration block."
  type        = string
  default     = "internal"
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the VM OS disk."
  type        = string
  default     = "Standard_LRS"
}
