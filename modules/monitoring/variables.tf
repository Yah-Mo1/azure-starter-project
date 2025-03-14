variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  default     = "UK South"
}

variable "action-group-email_address" {
  description = "The action group email reciever address"
}

variable "action-group-email-name" {
  description = "The action group email receiver name"

}

variable "la_workspace_name" {
  description = "The name of the log analytics workspace"

}
variable "action_group_name" {
  description = "The name of the Action group"

}

variable "vmss_id" {
  description = "The ID of the Virtual machine scale set"

}

variable "storage_account_name" {
  description = "The name of the storage account to store logs in"

}

variable "cpu_alert" {
  description = "The name of the CPU Alert resource"
  default     = "high-cpu-alert"

}