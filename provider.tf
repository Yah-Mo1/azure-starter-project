terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.21.1"
    }
  }
  //TODO: First create the azure storage account
  #   backend "azurerm" {
  #     resource_group_name  = "StorageAccount-ResourceGroup"  # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
  #     storage_account_name = "abcd1234"                      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
  #     container_name       = "tfstate"                       # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
  #     key                  = "prod.terraform.tfstate"        # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.

  # }

}

provider "azurerm" {
  # Configuration options
  #First Fix: Add features block here
  features {


  }
  #Second Fix: Add subscription_id and resource_provider_registration
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"

}