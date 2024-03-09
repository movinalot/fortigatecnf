locals {
  username = "azureuser"
  password = "Password123!!"

  resource_group_name = "${var.prefix}rg-fortigatecnf-vm"
  location            = "eastus"

  virtual_network_name_01 = "vnet-cnf"

  environment_tag = "CNF VM"

  resource_groups = {
    (local.resource_group_name) = {
      name     = local.resource_group_name
      location = local.location
      tags = {
        Environment = local.environment_tag
      }
    }
  }

  public_ips = {
    "pip-vm_access" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name              = "pip-vm_access"
      allocation_method = "Static"
      sku               = "Standard"
    }
  }

  vm_image = {
    "linux_vm" = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      vm_size   = "Standard_F2s_v2"
      version   = "latest"
      sku       = "18.04-LTS"
    }
  }

  virtual_networks = {
    (local.virtual_network_name_01) = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name          = local.virtual_network_name_01
      address_space = ["10.30.0.0/16"]
    }
  }

  subnets = {
    "snet-public" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-public"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name_01].name
      address_prefixes     = [cidrsubnet(azurerm_virtual_network.virtual_network[local.virtual_network_name_01].address_space[0], 8, 0)]
    }
    "snet-webservers" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-webservers"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name_01].name
      address_prefixes     = [cidrsubnet(azurerm_virtual_network.virtual_network[local.virtual_network_name_01].address_space[0], 8, 1)]
    }
  }

  network_interfaces = {
    "nic-web-1-eth1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-web-1-eth1"
      enable_ip_forwarding          = false
      enable_accelerated_networking = false

      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-webservers"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-webservers"].address_prefixes[0], 4)
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-vm_access"].id
        }
      ]
    }
  }

  network_security_groups = {
    "nsg-external" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "nsg-external"
    }
    "nsg-internal" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "nsg-internal"
    }
  }

  network_security_rules = {
    "nsgsr-external-ingress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-external-ingress"
      priority                    = 1001
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-external"].name
    },
    "nsgsr-external-egress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-external-egress"
      priority                    = 1002
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-external"].name
    },
    "nsgsr-internal-ingress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-internal-ingress"
      priority                    = 1001
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-internal"].name
    },
    "nsgsr-internal-egress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-internal-egress"
      priority                    = 1002
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-internal"].name
    }
  }

  subnet_network_security_group_associations = {
    "snet-public" = {
      subnet_id                 = azurerm_subnet.subnet["snet-public"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-external"].id
    }
    "snet-webservers" = {
      subnet_id                 = azurerm_subnet.subnet["snet-webservers"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-internal"].id
    }
  }

  linux_virtual_machines = {
    "vm-web-1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "vm-web-1"
      size = local.vm_image["linux_vm"].vm_size

      disable_password_authentication = "false"

      admin_username = local.username
      admin_password = local.password

      custom_data = base64encode(
        templatefile("${path.module}/linux-vm.tpl", {
          hostname = "vm-web-single"
        })
      )

      network_interface_ids = [azurerm_network_interface.network_interface["nic-web-1-eth1"].id]

      identity_type = "SystemAssigned"

      os_disk_name                 = "osdisk-vm-web-1"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"

      source_image_reference_publisher = local.vm_image["linux_vm"].publisher
      source_image_reference_offer     = local.vm_image["linux_vm"].offer
      source_image_reference_version   = local.vm_image["linux_vm"].version
      source_image_reference_sku       = local.vm_image["linux_vm"].sku

      identity_type = "SystemAssigned"

      tags_ComputeType = "WebServer"
    }
  }
}