# Provider
provider "azurerm" {
  version = "=3.0.0"
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-azure-sisnet"
  location = "westeurope"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-terraform-azure-sisnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-terraform-azure-sisnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "nic-terraform-azure-sisnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-terraform-azure-sisnet"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machine with password authentication and basic configuration
resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-terraform-azure-sisnet"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-terraform-azure-sisnet"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm-terraform-azure-sisnet"
    admin_username = "azureuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}