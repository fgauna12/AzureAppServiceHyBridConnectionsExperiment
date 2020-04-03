  
provider "azurerm" {
  version = "~>2.2.0"
  features {}
}

terraform {
  backend "azurerm" {}
}

locals {
  app_name_alphanumeric = replace(replace(var.app_name, "-", ""), "_", "")
  resource_group_name = "rg-${var.app_name}-${var.environment}"
  application_insights_name = "ai-${var.app_name}-${var.environment}"
  app_service_name = "azapp-${var.app_name}-${var.environment}"
  app_service_plan_name = "azappsp-${var.app_name}-${var.environment}"
  vm_name = "vmapp2${var.environment}001"
  vnet_name = "vnet-${var.app_name}-${var.environment}-001"
  subnet_name = "app2"
  nsg_name = "nsg-${var.app_name}-${var.environment}-001"
  public_ip = "pip-${var.app_name}-${var.environment}"
}

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = var.location
}