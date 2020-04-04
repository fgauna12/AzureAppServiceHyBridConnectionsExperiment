resource "azurerm_virtual_network" "virtual_network" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "main_subnet" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "nic" {
  name                = local.nsg_name
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main_subnet.id
    private_ip_address_alLOCATION = "Dynamic"
    primary                       = true
  }

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.main_subnet.id
    private_ip_address_alLOCATION = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.LOCATION
  size                = "Standard_F2"
  admin_username      = var.VM_ADMIN_USERNAME
  admin_password      = var.VM_ADMIN_PASSWORD
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                    = local.public_ip
  location                = var.LOCATION
  resource_group_name     = azurerm_resource_group.resource_group.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_virtual_machine_extension" "vm_extension_azuredevops" {
  name                       = "vm_extension_azuredevops"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.VisualStudio.Services"
  type                       = "TeamServicesAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "VSTSAccountName": "${var.AZURE_DEVOPS_ORGANIZATION}",
        "TeamProject": "${var.AZURE_DEVOPS_TEAMPROJECT}",
        "DeploymentGroup": "${var.AZURE_DEVOPS_DEPLOYMENTGROUP}",
        "AgentName": "${local.vm_name}"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "PATToken": "${var.AZURE_DEVOPS_PAT}"
    }
PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS
}
