# check minimum version of terraform & cloud provider
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99.0"
      #version = "= 3.19"
    }
  }
}


# select cloud provider
provider "azurerm" {
  features {}
subscription_id = ""
tenant_id       = ""
client_id       = ""
client_secret = ""
#client_secret   = ""
}

output "CCIP" {
  value = var.CC_IP
}

output "CCRange" {
  value = var.CC_Range
}

output "CCluster" {
  value = var.CC_Cluster
}

output "CCBox" {
  value = var.CC_Box
}

resource "azurerm_resource_group" "cgf-rg" {
    name = "${var.prefix}"
    location = var.location 
    tags = {
        "Owner" = "apreck@barracuda.com"
        "deployes-with" = "terraform"
        "persistant"    = "no"
    }
}
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNET"
  address_space       = ["${var.vnet}"]
  location            = "${azurerm_resource_group.cgf-rg.location}"
  resource_group_name = "${azurerm_resource_group.cgf-rg.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.prefix}-SUBNET-CGF"
  resource_group_name  = "${azurerm_resource_group.cgf-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefixes       = ["${var.subnet_cgf}"]
}

/* resource "azurerm_subnet_route_table_association" "protected-default" {
  subnet_id      = azurerm_subnet.subnet2.id
  route_table_id = azurerm_route_table.defaultroute.id
} */

#######VM
resource "azurerm_public_ip" "cgf-pip" {
  name                         = "${var.prefix}-VM-NGF-PIP"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.cgf-rg.name}"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "cgf-ifc" {
  name                = "${var.prefix}-VM-CGF-IFC"
  location            = "${azurerm_resource_group.cgf-rg.location}"
  resource_group_name = "${azurerm_resource_group.cgf-rg.name}"
  enable_ip_forwarding  = true
  ip_configuration {
    name                          = "interface1"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.cgf_ipaddress}"
    public_ip_address_id          = "${azurerm_public_ip.cgf-pip.id}"
  }
}

resource "azurerm_network_security_group" "cgf_nsg" {
  name                = "${var.prefix}-CGF-NSG"
  location            = var.location
  resource_group_name = "${azurerm_resource_group.cgf-rg.name}"
}

resource "azurerm_network_security_rule" "csg_nsg_allowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = "${azurerm_resource_group.cgf-rg.name}"
  network_security_group_name = "${azurerm_network_security_group.cgf_nsg.name}"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "csg_nsg_allowallin" {
  name                        = "Allow-ALL-Inbound"
  resource_group_name         = "${azurerm_resource_group.cgf-rg.name}"
  network_security_group_name = "${azurerm_network_security_group.cgf_nsg.name}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

/* resource "azurerm_route_table" "defaultroute" {
  name                = "${var.prefix}-RT-DEFAULT"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cgf-rg.name}"

  route {
    name                = "${var.prefix}-protected-to-internet"
    address_prefix          = "0.0.0.0/0"
    next_hop_type           = "VirtualAppliance"
    next_hop_in_ip_address  = "${var.cgf_ipaddress}"
  }
} */
resource "azurerm_virtual_machine" "cgf-vm" {
  name                  = "${var.prefix}-VM-CGF"
  location              = "${azurerm_resource_group.cgf-rg.location}"
  resource_group_name   = "${azurerm_resource_group.cgf-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.cgf-ifc.id}"]
  vm_size               = "${var.cgf_vmsize}"

  storage_image_reference {
    publisher = "barracudanetworks"
    offer     = "barracuda-ng-firewall"
    sku       = "${var.cgf_imagesku}"
    version   = "latest"
  }

  plan {
    publisher = "barracudanetworks"
    product   = "barracuda-ng-firewall"
    name      = "${var.cgf_imagesku}"
  }

  storage_os_disk {
    name              = "${var.prefix}-VM-CGF-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

/* data "template_file" "startup_script" {
  template = file("script-cgf.sh")
  vars = {
        CC_IP = var.CC_IP
        CC_User = var.CC_User
        CC_Cluster = var.CC_Cluster
        CC_Range = var.CC_Range
        CC_Box = var.CC_Box
        pwd = var.SharedKey 
    //you can use any variable directly here
  }
} */

  os_profile {
    computer_name  = "${var.prefix}-VM-CGF"
    admin_username = "azureuser"
    admin_password = "${var.password}"
    custom_data = templatefile("init.tftpl", {
        CC_IP = var.CC_IP
        CC_User = var.CC_User
        CC_Cluster = var.CC_Cluster
        CC_Range = var.CC_Range
        CC_Box = var.CC_Box
        pwd = var.SharedKey
        NGFIP =var.cgf_ipaddress
        NGFNM = var.cgf_subnetmask 
        NGFGW = var.cgf_defaultgateway
   } ) 
}

  os_profile_linux_config {
    disable_password_authentication = false
  }

}
