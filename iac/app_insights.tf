resource "azurerm_application_insights" "insights" {
  name                = local.application_insights_name
  LOCATION            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
}

