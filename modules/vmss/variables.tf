variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
}

variable "vmss_name" {
  description = "The name of the Virtual Machine Scale Set"
  type        = string
}

variable "vmss_sku" {
  description = "The SKU for the Virtual Machine Scale Set"
  type        = string
}

variable "vmss_instances" {
  description = "The number of instances for the Virtual Machine Scale Set"
  type        = number
  default     = 3
}

variable "vmss_zones" {
  description = "Availability Zones for the Virtual Machine Scale Set"
  type        = list(string)
}

variable "admin_username" {
  description = "Admin username for the VMSS"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the Virtual Machine Scale Set"
  type        = string
}

variable "app_gateway_backend_address_pool_ids" {
  description = "Backend address pool IDs for the Application Gateway"
  type        = list(string)
}

variable "log_analytics_workspace_id" {
  description = "The ID of the log analytics workspace"
  
}

variable "storage_account_id" {
  description = "The ID of the storage account used to store logs"
  
}