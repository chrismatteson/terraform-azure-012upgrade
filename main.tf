resource "random_id" "projectname" {
  byte_length = 4
}

resource "azurerm_resource_group" "main" {
  name     = random_id.projectname.hex
  location = "West US"
}

resource "azurerm_network_security_group" "main" {
  name                = "${random_id.projectname.hex}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_virtual_network" "main" {
  name                = "${random_id.projectname.hex}-vn"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  dynamic "subnet" {
    for_each = [1,2,3]
    content {
      name           = "subnet${subnet.key+1}"
      address_prefix = "10.0.${subnet.value}.0/24"
      security_group = "${azurerm_network_security_group.main.id}"
    }
  }

  tags = {
    environment = "Production"
  }
}

