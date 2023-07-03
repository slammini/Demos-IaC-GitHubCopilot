# Create a new Azure virtual machine with password authentication

# Provider
provider "azurerm" {
  features {}
}

# Resource
resource "azurerm_resource_group" "rg" {
  name     = "Test-CC-TerraformVM"
  location = "westeurope"
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "Test-CC-TerraformVM-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "Test-CC-TerraformVM-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "publicip" {
  name                = "Test-CC-TerraformVM-publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create newtork interface
resource "azurerm_network_interface" "nic" {
  name                = "Test-CC-TerraformVM-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "Test-CC-TerraformVM-nic-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create a virtual machine with password authentication and basic configuration
resource "azurerm_virtual_machine" "vm" {
  name                  = "Test-CC-TerraformVM"
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
    name              = "Test-CC-TerraformVM-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Test-CC-TerraformVM"
    admin_username = "azureuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "Terraform Demo"
  }
}
```