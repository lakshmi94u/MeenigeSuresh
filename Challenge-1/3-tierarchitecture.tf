resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = var.address_space
  #dns_servers = ""
  tags = var.tags

}

resource "azurerm_subnet" "app-subnet" {
  name = "app-subnet"
  resource_group_name = var.resource_group_name
  address_prefixes = ["192.168.1.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_subnet" "db-subnet" {
  name = "db-subnet"
  resource_group_name = var.resource_group_name
  address_prefixes = ["192.168.2.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_subnet" "web-subnet" {
  name = "web-subnet"
  resource_group_name = var.resource_group_name
  address_prefixes = ["192.168.0.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_route_table" "rtable" {
  count = length(var.route_table_name)
  name                = var.route_table_name[count.index]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_route_table" "rtable-db" {
  name                = "route-db"
  location            = var.location
  resource_group_name = var.resource_group_name

}

/*
resource "azurerm_route" "subnet-routes" {
  name                = var.route_table_name
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.rtable.name
  address_prefix      = var.address_prefixes[count.index]
 
}

resource "azurerm_subnet_route_table_association" "subnet_routetable_association" {
  count = length(var.subnet_ids)
  subnet_id = var.subnet_ids[count.index]
   route_table_id = azurerm_route_table.rtable[count.index].id
}
*/
resource "azurerm_network_security_group" "network_group" {
  count = length(var.nsg_name)
  name = var.nsg_name[count.index]
  resource_group_name = var.resource_group_name
  location = var.location
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "subnet_association" {
   count = length(var.subnet_ids)
    subnet_id = var.subnet_ids[count.index]
    network_security_group_id = azurerm_network_security_group.network_group[count.index].id 
} 


resource "azurerm_availability_set" "web-av" {
  name                = "web-avset"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = var.tags
}

resource "azurerm_network_interface" "windows_vm_nic" {
  count = length(var.subnet_ids)
  name = "app-vm-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_accelerated_networking = true
  ip_configuration {
    name = "ipconfig1"
    subnet_id = var.subnet_ids[0]
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "win_vm" {
  name = "web-vm01"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = "Standard_D2ds_v4"
  admin_username = "azureuser"
  admin_password = "hello@0523"
  encryption_at_host_enabled = false
  availability_set_id = azurerm_availability_set.web-av.id
  

  tags = var.tags
  
  network_interface_ids = [
    azurerm_network_interface.windows_vm_nic[0].id,
  ]
os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}



resource "azurerm_network_interface" "linux_vm_nic" {
  count = length(var.subnet_ids)
  name = "appserver-vm-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_accelerated_networking = true
  ip_configuration {
    name = "ipconfig1"
    subnet_id = var.subnet_ids[1]
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "app_vm" {
  name = "app-vm01"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = "Standard_D2ds_v4"
  admin_username = "azureuser"
 
  encryption_at_host_enabled = false
  availability_set_id = azurerm_availability_set.app-av.id
  tags = var.tags
  disable_password_authentication = false
  admin_password  = "paSuress09123@"
  admin_ssh_key {
   username = "azureuser"
  public_key = file("~/.ssh/id_rsa.pub")
  }
  
  
  network_interface_ids = [
    azurerm_network_interface.linux_vm_nic[1].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" 
}
 source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  depends_on = [
    azurerm_availability_set.app-av
  ]
}


resource "azurerm_availability_set" "app-av" {
  name                = "app-avset"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = var.tags
}


resource "azurerm_sql_server" "example" {
  name                         = "demosqltestchallange"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
  tags = var.tags
  
}

resource "azurerm_sql_database" "example" {
  name                = "demo_db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.example.name
  tags =var.tags
}

resource "azurerm_lb" "example" {
  name                = "app-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "privateip-app"
    private_ip_address_allocation = "Static"
    private_ip_address = "192.168.1.6"
    subnet_id = azurerm_subnet.app-subnet.id
  }
}

resource "azurerm_recovery_services_vault" "vault" {
  name = "rsv"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  soft_delete_enabled = true
  tags = var.tags
  sku = "Standard"
  /*identity {
    type = "SystemAssigned"
  } */
}


resource "azurerm_lb_backend_address_pool" "bep" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "BackEndAddressPool"
}
/*
resource "azurerm_lb_backend_address_pool_address" "example-1" {
  name                                = "address1"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.bep.id
  backend_address_ip_configuration_id =  azurerm_network_interface.windows_vm_nic[0].id
}*/