provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "Azuredevops"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags = {
    project = "${var.prefix}"
  }
}

resource "azurerm_subnet" "sn" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_number
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    project = "${var.prefix}"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = {
    project = "${var.prefix}"
  }
}

resource "azurerm_network_security_rule" "nsr-allow-inbound-internal" {
  name                        = "allow_internal_inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/16"
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.rg.name
}

resource "azurerm_network_security_rule" "nsr-allow-outbound-internal" {
  name                        = "allow_internal_outbound"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/16"
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.rg.name
}

resource "azurerm_network_security_rule" "nsr-deny-inbound-external" {
  name                        = "deny_external_inbound"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.rg.name
}


resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    project = "${var.prefix}"
  }
}

resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-lb"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = {
    project = "${var.prefix}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_ap" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "${var.prefix}-BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_b_ap_a" {
  count                   = var.vm_number
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "${var.prefix}-testconfiguration1"
  backend_address_pool_id = element(azurerm_lb_backend_address_pool.lb_ap.*.id, count.index)
}

resource "azurerm_availability_set" "as" {
  name                = "${var.prefix}-aset"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags = {
    project = "${var.prefix}"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.vm_number
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]
  source_image_id = data.azurerm_image.custom_image.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  tags = {
    project = "${var.prefix}"
  }
}

resource "azurerm_managed_disk" "md" {
  count                = var.vm_number
  name                 = "${var.prefix}-md-${count.index}"
  location             = data.azurerm_resource_group.rg.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  tags = {
    project = "${var.prefix}"
  }

}
