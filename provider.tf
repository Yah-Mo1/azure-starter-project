terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.21.1"
    }
  }
  //TODO: First create the azure storage account
    backend "azurerm" {
      resource_group_name  = "tfstate-rg"# Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
      storage_account_name = "codercostorageacc"                      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
      container_name       = "coderco-tfstate-container"                       # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
      key                  = "devpipeline.terraform.tfstate"        # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.

  }

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