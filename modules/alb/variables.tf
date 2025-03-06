variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "coderco-tech-test"
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  default     = "UK South"
}

variable "app_gateway_name" {
  description = "The name of the Application Gateway"
  type        = string
}

variable "app_gateway_sku" {
  description = "SKU for the Application Gateway"
  type        = string
}

variable "app_gateway_tier" {
  description = "Tier of the Application Gateway"
  type        = string
}

variable "app_gateway_capacity" {
  description = "Capacity of the Application Gateway"
  type        = number
}

variable "subnet_id" {
  description = "Subnet ID for the Application Gateway"
  type        = string
}

variable "public_ip_id" {
  description = "Public IP ID for the Application Gateway"
  type        = string
}
