# create our resource group
resource "azurerm_resource_group" "rg" {
    location = var.resource_group_location
    name = "${var.base_name}-malrdp-deployment"
}

# create our virtual network
resource "azurerm_virtual_network" "vnet" {
    name = "${var.base_name}-vnet"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# create a subnet
resource "azurerm_subnet" "subnet" {
    name = "${var.base_name}-subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.0.0/24"]
}

# create the public IP
resource "azurerm_public_ip" "public_ip" {
    name = "${var.base_name}-ip"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Dynamic"
}

# create the network security group and rules
resource "azurerm_network_security_group" "nsg" {
    name = "${var.base_name}-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "Allow-RDP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "${local.public_ip}/32"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Allow-WinRM"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5985-5986"
        source_address_prefix      = "${local.public_ip}/32"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Allow-HTTP"
        priority                   = 102
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Allow-HTTPS"
        priority                   = 103
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# create the network interface
resource "azurerm_network_interface" "nic" {
    name = "${var.base_name}-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "nic-configuration"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}

# connect the nsg to the nic
resource "azurerm_network_interface_security_group_association" "assoc" {
    network_interface_id = azurerm_network_interface.nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# create virtual machine
resource "azurerm_windows_virtual_machine" "main" {
    name = "${var.base_name}-vm"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic.id]
    size = "${var.vm_size}"

    admin_username = "${var.admin_user}"
    admin_password = "${var.admin_pass}"
    computer_name = "${var.host_name}"

    os_disk {
        name = "OS_Disk"
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2022-datacenter-azure-edition"
        version = "latest"
    }

    winrm_listener {
        protocol = "Http"
    }

    provisioner "local-exec" {
        working_dir = "${path.root}/../ansible"
        command = "ansible-playbook setup.yml -i '${azurerm_windows_virtual_machine.main.public_ip_address},' -e 'ansible_user=${var.admin_user}' -e 'ansible_password=${var.admin_pass}' -e 'host_name=${var.host_name}' -e 'victim_user=${var.victim_user}' -v"
    }
}