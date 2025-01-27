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
        "fileUris" : ["https://sqsandboxpostdeployment.blob.core.windows.net/bashfile/postdeploy.sh?sp=r&st=2025-01-27T11:37:40Z&se=2025-06-01T18:37:40Z&spr=https&sv=2022-11-02&sr=b&sig=1s0SwPWqMaeeKCjGBiLyfbMUPLTY3VoqgwUje0WF%2BrY%3D"],
        "commandToExecute": "bash postdeploy.sh ${var.sq_version}"
    }
SETTINGS

  depends_on = [azurerm_linux_virtual_machine.main]
}