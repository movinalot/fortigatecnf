locals {
  username = "azureuser"
  password = "Password123!!"

  resource_group_name = "${var.prefix}rg-fortigatecnf-vms-user-elb"
  location            = "eastus"

  virtual_network_name_01 = "vnet-cnf"

  environment_tag = "CNF VMs USER ELB"

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
      address_space = ["10.20.0.0/16"]
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
          public_ip_address_id          = null
        }
      ]
    }
    "nic-web-2-eth1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-web-2-eth1"
      enable_ip_forwarding          = false
      enable_accelerated_networking = false

      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-webservers"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-webservers"].address_prefixes[0], 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-web-3-eth1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-web-3-eth1"
      enable_ip_forwarding          = false
      enable_accelerated_networking = false

      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-webservers"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-webservers"].address_prefixes[0], 6)
          public_ip_address_id          = null
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

  nsg_rules_lists = [
    ["nsg-external", "nsgsr-external-ingress"],
    ["nsg-external", "nsgsr-external-egress"],
    ["nsg-internal", "nsgsr-internal-ingress"],
    ["nsg-internal", "nsgsr-internal-egress"]
  ]

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
          hostname = "vm-web-1"
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
    "vm-web-2" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "vm-web-2"
      size = local.vm_image["linux_vm"].vm_size

      disable_password_authentication = "false"

      admin_username = local.username
      admin_password = local.password

      custom_data = base64encode(
        templatefile("${path.module}/linux-vm.tpl", {
          hostname = "vm-web-2"
        })
      )

      network_interface_ids = [azurerm_network_interface.network_interface["nic-web-2-eth1"].id]

      identity_type = "SystemAssigned"

      os_disk_name                 = "osdisk-vm-web-2"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"

      source_image_reference_publisher = local.vm_image["linux_vm"].publisher
      source_image_reference_offer     = local.vm_image["linux_vm"].offer
      source_image_reference_version   = local.vm_image["linux_vm"].version
      source_image_reference_sku       = local.vm_image["linux_vm"].sku

      tags_ComputeType = "WebServer"
    }
    "vm-web-3" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "vm-web-3"
      size = local.vm_image["linux_vm"].vm_size

      disable_password_authentication = "false"

      admin_username = local.username
      admin_password = local.password

      custom_data = base64encode(
        templatefile("${path.module}/linux-vm.tpl", {
          hostname = "vm-web-3"
        })
      )

      network_interface_ids = [azurerm_network_interface.network_interface["nic-web-3-eth1"].id]

      identity_type = "SystemAssigned"

      os_disk_name                 = "osdisk-vm-web-3"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"

      source_image_reference_publisher = local.vm_image["linux_vm"].publisher
      source_image_reference_offer     = local.vm_image["linux_vm"].offer
      source_image_reference_version   = local.vm_image["linux_vm"].version
      source_image_reference_sku       = local.vm_image["linux_vm"].sku

      tags_ComputeType = "WebServer"
    }
  }

  lbs = {
    "lbe-external" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "lbe-external"
      sku  = "Standard"
      frontend_ip_configurations = [
        {
          name                 = "lbe-external_fe_ip"
          public_ip_address_id = azurerm_public_ip.public_ip["pip-vm_access"].id
        }
      ]
    }
  }

  lb_backend_address_pools = {
    "lbe-external_pool" = {
      name            = "lbe-external_pool"
      loadbalancer_id = azurerm_lb.lb["lbe-external"].id
    }
  }

  network_interface_backend_address_pool_associations = {
    "nic-web-1-eth1" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-web-1-eth1"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id
    }
    "nic-web-2-eth1" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-web-2-eth1"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id
    }
    "nic-web-3-eth1" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-web-3-eth1"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id
    }
  }

  lb_probes = {
    "lbe-external_probe" = {
      name                = "lbe-external_probe"
      loadbalancer_id     = azurerm_lb.lb["lbe-external"].id
      port                = "80"
      interval_in_seconds = 5
    }
  }

  lb_rules = {
    "rule-tcp_80" = {
      name                           = "rule-tcp_80"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      frontend_ip_configuration_name = "lbe-external_fe_ip"
      protocol                       = "Tcp"
      frontend_port                  = "80"
      backend_port                   = "80"
      backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id]
      probe_id                       = azurerm_lb_probe.lb_probe["lbe-external_probe"].id
      disable_outbound_snat          = true
    }
  }

  lb_nat_rules = {
    "web-vm_1_ssh" = {
      resource_group_name            = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                           = "web-vm_1_ssh"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "10122"
      backend_port                   = "22"
      frontend_ip_configuration_name = azurerm_lb.lb["lbe-external"].frontend_ip_configuration[0].name
    }
    "web-vm_2_ssh" = {
      resource_group_name            = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                           = "web-vm_2_ssh"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "10222"
      backend_port                   = "22"
      frontend_ip_configuration_name = azurerm_lb.lb["lbe-external"].frontend_ip_configuration[0].name
    }
    "web-vm_3_ssh" = {
      resource_group_name            = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                           = "web-vm_3_ssh"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "10322"
      backend_port                   = "22"
      frontend_ip_configuration_name = azurerm_lb.lb["lbe-external"].frontend_ip_configuration[0].name
    }
  }

  network_interface_nat_rule_associations = {
    "web-vm_1_ssh" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-web-1-eth1"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["web-vm_1_ssh"].id
    }
    "web-vm_2_ssh" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-web-2-eth1"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["web-vm_2_ssh"].id
    }
    "web-vm_3_ssh" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-web-3-eth1"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["web-vm_3_ssh"].id
    }
  }

  lb_outbound_rules = {
    "rule-all_outbound" = {
      resource_group_name     = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                    = "rule-all_outbound"
      loadbalancer_id         = azurerm_lb.lb["lbe-external"].id
      protocol                = "All"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id
      frontend_ip_configurations = [
        {
          name = azurerm_lb.lb["lbe-external"].frontend_ip_configuration[0].name
        }
      ]
    }
  }
}