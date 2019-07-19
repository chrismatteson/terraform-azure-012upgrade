resource "random_id" "projectname" {
  byte_length = 4
}

resource "azurerm_resource_group" "main" {
  name     = "${random_id.projectname.hex}"
  location = "West US"
}

resource "azurerm_network_security_group" "main" {
  name                = "${random_id.projectname.hex}-nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_network_ddos_protection_plan" "main" {
  name                = "${random_id.projectname.hex}-ddospplan"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_virtual_network" "main" {
  name                = "${random_id.projectname.hex}-vn"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  ddos_protection_plan {
    id     = "${azurerm_network_ddos_protection_plan.main.id}"
    enable = true
  }

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
    security_group = "${azurerm_network_security_group.main.id}"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = "${azurerm_network_security_group.main.id}"
  }

  subnet {
    name           = "subnet3"
    address_prefix = "10.0.3.0/24"
    security_group = "${azurerm_network_security_group.main.id}"
  }

  tags = {
    environment = "Production"
  }
}
