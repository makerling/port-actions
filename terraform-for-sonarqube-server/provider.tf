provider "azurerm" {
  # skip_provider_registration = "true"
  subscription_id = "4bf2f5ef-072c-475b-aa17-5accdfbe769f"
  # resource_provider_registrations = "none" - only needed for sandbox
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }

  }
}