# Create a new Azure virtual machine with password authentication
# Create a new resource group, a new virtual network, a new subnet, a new public IP address, a new network interface, and a new virtual machine with basic configuration

# Provider
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "CloudChampion-Terraform-Demo"
  location = "westeurope"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "CloudChampion-Terraform-Demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "CloudChampion-Terraform-Demo-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Public IP
resource "azurerm_public_ip" "publicip" {
  name                = "CloudChampion-Terraform-Demo-publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "CloudChampion-Terraform-Demo-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "CloudChampion-Terraform-Demo-nic-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Virtual Machine with basic configuration
resource "azurerm_virtual_machine" "vm" {
  name                  = "CloudChampion-Terraform-Demo-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "CloudChampion-Terraform-Demo-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "CloudChampion-Terraform-Demo-vm"
    admin_username = "cloudchampion"
    admin_password = "CloudChampion123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


