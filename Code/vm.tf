# Create a new Azure Virtual Machine with basic configuation and password based authentication using terraform
# Create a resource group, a virtual netwrok, a subnet, a public IP address, a network interface, a virtual machine

#Provider


#Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "test-IaC-Terraform-GitHubActions"
  location = "westeurope"
}

#Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "test-IaC-Terraform-GitHubActions-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "test-IaC-Terraform-GitHubActions-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

#Public IP
resource "azurerm_public_ip" "publicip" {
  name                = "test-IaC-Terraform-GitHubActions-publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

#Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "test-IaC-Terraform-GitHubActions-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "test-IaC-Terraform-GitHubActions-nic-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

#Virtual Machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "test-IaC-Terraform-GitHubActions-vm"
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
    name              = "test-IaC-Terraform-GitHubActions-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "test-IaC-Terraform-GitHubActions-vm"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}



