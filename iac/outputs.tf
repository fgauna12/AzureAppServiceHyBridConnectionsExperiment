output "app_service" {
    value = azurerm_app_service.app_service.name
}

output "app_insights_instrumentation_key" {
    value = azurerm_application_insights.insights.instrumentation_key    
}
