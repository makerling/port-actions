provider "azurerm" {
  # skip_provider_registration = "true"
  subscription_id = "4bf2f5ef-072c-475b-aa17-5accdfbe769f"
  # resource_provider_registrations = "none" - only needed for sandbox
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

data "azurerm_resource_group" "rg" {
  name = "SonarQubeSandbox"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-static-website"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "vm_subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "net_sg" {
  name                = "network_sg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  #   Allow SSH traffic from anywhere
  security_rule {
    name                       = "Allow_SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP traffic from anywhere
  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
      name                       = "Sonarqube"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
}

resource "azurerm_public_ip" "publicip" {
  name                = "publicip-vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vmnic" {
  name                = "vmnic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_network_interface_security_group_association" "sg_assoc" {
  network_interface_id      = azurerm_network_interface.vmnic.id
  network_security_group_id = azurerm_network_security_group.net_sg.id
}


resource "azurerm_linux_virtual_machine" "main" {
  name                              = "sonar-server"
  resource_group_name               = data.azurerm_resource_group.rg.name
  location                          = data.azurerm_resource_group.rg.location
  size                              = "Standard_D2s_v3"
  admin_username                    = "adminuser"
  admin_password                    = var.admin_password
  network_interface_ids             = [azurerm_network_interface.vmnic.id]
  disable_password_authentication   = false

  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/devazurekey.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# resource "azurerm_virtual_machine_extension" "script" {
#   name                 = "script-extension"
#   virtual_machine_id   = azurerm_linux_virtual_machine.main.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.1"

#   settings = <<SETTINGS
#     {
#         "fileUris" : ["https://sqsandboxpostdeployment.blob.core.windows.net/bashfile/postdeploy.sh?sp=r&st=2025-01-27T11:37:40Z&se=2025-06-01T18:37:40Z&spr=https&sv=2022-11-02&sr=b&sig=1s0SwPWqMaeeKCjGBiLyfbMUPLTY3VoqgwUje0WF%2BrY%3D"],
#         "commandToExecute": "bash postdeploy.sh ${var.sq_version}"
#     }
# SETTINGS

#   depends_on = [azurerm_linux_virtual_machine.main]
# }