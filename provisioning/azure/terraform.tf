provider "azurerm" {
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    features {}
}

resource "azurerm_resource_group" "meicm" {
    name     = "meicm-group"
    location = "West Europe"

    tags = {
        environment = "MEICM"
    }
}

resource "azurerm_virtual_network" "meicm" {
    name                = "meicm-network"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.meicm.location
    resource_group_name = azurerm_resource_group.meicm.name

    tags = {
        environment = "MEICM"
    }
}

resource "azurerm_subnet" "meicm" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.meicm.name
  virtual_network_name = azurerm_virtual_network.meicm.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "meicm" {
  name                = "meicm-pip"
  resource_group_name = azurerm_resource_group.meicm.name
  location            = azurerm_resource_group.meicm.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "meicm" {
  name                = "meicm-nic"
  location            = azurerm_resource_group.meicm.location
  resource_group_name = azurerm_resource_group.meicm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.meicm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.meicm.id
  }
}

resource "azurerm_linux_virtual_machine" "meicm" {
  name                = "meicm-machine"
  resource_group_name = azurerm_resource_group.meicm.name
  location            = azurerm_resource_group.meicm.location
  size                = "Standard_F2"
  admin_username      = var.user
  admin_password      = var.password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.meicm.id,
  ]

  admin_ssh_key {
    username   = var.user
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

data "azurerm_public_ip" "meicm" {
  name                = azurerm_public_ip.meicm.name
  resource_group_name = azurerm_resource_group.meicm.name
}

output "Public-IP" {
  description = "id of the public ip address provisoned."
  value       = data.azurerm_public_ip.meicm.ip_address
}