resource "azurerm_resource_group" "web" {
  name     = "web"
  location = "East US"
}

resource "azurerm_virtual_network" "web_network" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.web.location
  resource_group_name = azurerm_resource_group.web.name
}

resource "azurerm_subnet" "web_subnet-1" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.web.name
  virtual_network_name = azurerm_virtual_network.web_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "web_subnet-2" {
  name                 = "example-subnet2"
  resource_group_name  = azurerm_resource_group.web.name
  virtual_network_name = azurerm_virtual_network.web_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "web_interface-1" {
  name                = "example-nic"
  location            = azurerm_resource_group.web.location
  resource_group_name = azurerm_resource_group.web.name

  ip_configuration {
    name                          = "example-config"
    subnet_id                     = azurerm_subnet.web_subnet-1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "web_interface-2" {
  name                = "example-nic2"
  location            = azurerm_resource_group.web.location
  resource_group_name = azurerm_resource_group.web.name

  ip_configuration {
    name                          = "example-config2"
    subnet_id                     = azurerm_subnet.web_subnet-2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "linux-vm" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  size                = "Standard_A0"
  admin_username      = "adminuser"

  network_interface_ids = [azurerm_network_interface.web_interface-1.id]

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

  # custom_data = base64encode(file("./script/user_data.sh"))
}

resource "azurerm_linux_virtual_machine" "vm-1" {
  name                = "example-machine2"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  size                = "Standard_A0"
  admin_username      = "adminuser"

  network_interface_ids = [azurerm_network_interface.web_interface-2.id]

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

  # custom_data = base64encode(file("${path.module}/script/user_data.sh"))
}

resource "azurerm_lb" "lb" {
  name                = "example-lb"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.azure_ip.id
  }
}

resource "azurerm_public_ip" "azure_ip" {
  name                = "example-lb-public-ip"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  allocation_method   = "Static"
}

resource "azurerm_lb_backend_address_pool" "lb_pool" {
  name                = "example-lb-backend-pool"
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = "example-lb-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  port                = 80
  protocol            = "Tcp"
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "example-lb-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.lb_pool.id]
  frontend_port                  = 80
  backend_port                   = 80
  protocol                       = "Tcp"
}

