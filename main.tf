# creating resource group from local variable 
resource "azurerm_resource_group" "appgrp" {
  name     = local.resource_group_name
  location = local.location
}


# creating network interface for linux vm
resource "azurerm_network_interface" "appinterface" {
  name                = "appinterface"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.appip.id
  }
  depends_on = [
    azurerm_subnet.subnetA
  ]
}

# associating nic card to vm
resource "azurerm_subnet_network_security_group_association" "appnsglink" {
  subnet_id                 = azurerm_subnet.subnetA.id
  network_security_group_id = azurerm_network_security_group.appnsg.id
}



# creating linux vm with standard size d2s 
resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                            = "linuxvm"
  resource_group_name             = local.resource_group_name
  location                        = local.location
  user_data                       = base64encode(local.user_data)
  size                            = "Standard_D2s_v3"
  admin_username                  = "linuxusr"
  admin_password                  = "azure@123@321"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.appinterface.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.appinterface,
    azurerm_resource_group.appgrp

  ]
}
# Custom script to install Apache
resource "azurerm_virtual_machine_extension" "example" {
  name                 = "Apache"
  virtual_machine_id   = azurerm_linux_virtual_machine.linuxvm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt update && sudo apt install -y apache2"
    }
SETTINGS
}

