variable "subscription_id" {
  description = "The ID of the subscription"

}

variable "email_address" {
  description = "The Email address to Send Autoscaling alerts to"

}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}


/// VPC Variables

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnets within the virtual network"
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
}

variable "public_ip_name" {
  description = "The name of the public IP address"
  type        = string
}

variable "public_ip_allocation" {
  description = "The allocation method for the public IP"
  type        = string
  default     = "Static"
}

variable "network_security_group_name" {
  description = "The name of the network security group"
  type        = string
}

variable "inbound_ports_map" {
  description = "Map of inbound ports for security rules"
  type        = map(string)
  default = {
    "100" = "80"
    "110" = "443"
    "130" = "65200-65535"
  }
}


// ALB Variables

variable "app_gateway_name" {
  description = "The name of the Application Gateway"
  type        = string
}

variable "app_gateway_sku" {
  description = "SKU for the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "app_gateway_tier" {
  description = "Tier of the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "app_gateway_capacity" {
  description = "Capacity of the Application Gateway"
  type        = number
  default     = 2
}

# variable "public_ip_id" {
#   description = "Public IP ID for the Application Gateway"
#   type        = string
# }


// VMSS Variables

variable "vmss_name" {
  description = "The name of the Virtual Machine Scale Set"
  type        = string
  default     = "coderco-vmss"
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
  default     = ["1", "2", "3"]
}

variable "admin_username" {
  description = "Admin username for the VMSS"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}


# variable "app_gateway_backend_address_pool_ids" {
#   description = "Backend address pool IDs for the Application Gateway"
#   type        = list(string)
# }
