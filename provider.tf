terraform {

  # required_version = ">= 1.3.0, < 1.6.0" # Move this outside required_providers

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.21.1"
    }

  }
  //TODO: First create the azure storage account
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "codercostorageacc"
    container_name       = "coderco-tfstate-container"
    key                  = "devpipeline.terraform.tfstate"

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