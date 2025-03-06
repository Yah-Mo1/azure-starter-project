variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
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
}

variable "network_security_group_name" {
  description = "The name of the network security group"
  type        = string
}

variable "inbound_ports_map" {
  description = "Map of inbound ports for security rules"
  type        = map(string)
}
