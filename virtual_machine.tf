variable "admin_password" {
  description = "The admin password for the VM"
  type        = string
  sensitive   = true
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

resource "azurerm_virtual_machine_extension" "script" {
  name                 = "script-extension"
  virtual_machine_id   = azurerm_linux_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "fileUris" : ["https://sqsandboxpostdeployment.blob.core.windows.net/bashfile/postdeploy6.sh?sp=r&st=2025-01-27T03:06:20Z&se=2025-03-01T11:06:20Z&spr=https&sv=2022-11-02&sr=b&sig=mCk0Maqj6PDvUnAR%2Be1vnwZP1MS55nXh7oYgugdZc%2F0%3D"],
        "commandToExecute": "bash postdeploy6.sh"
    }
SETTINGS

  depends_on = [azurerm_linux_virtual_machine.main]
}