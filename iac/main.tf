  
provider "azurerm" {
  version = "~>2.2.0"
  features {}
}

terraform {
  backend "azurerm" {}
}

locals {
  APP_NAME_alphanumeric = replace(replace(var.APP_NAME, "-", ""), "_", "")
  resource_group_name = "rg-${var.APP_NAME}-${var.ENVIRONMENT}"
  application_insights_name = "ai-${var.APP_NAME}-${var.ENVIRONMENT}"
  app_service_name = "azapp-${var.APP_NAME}-${var.ENVIRONMENT}"
  app_service_plan_name = "azappsp-${var.APP_NAME}-${var.ENVIRONMENT}"
  vm_name = "vmapp2${var.ENVIRONMENT}001"
  vnet_name = "vnet-${var.APP_NAME}-${var.ENVIRONMENT}-001"
  subnet_name = "app2"
  nsg_name = "nsg-${var.APP_NAME}-${var.ENVIRONMENT}-001"
  public_ip = "pip-${var.APP_NAME}-${var.ENVIRONMENT}"
}

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = var.LOCATION
}