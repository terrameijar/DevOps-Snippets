terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.37.0"
    }
  }
}



provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a resource group
resource "azurerm_resource_group" "migration-lab-tf" {
  name     = "tf-migration-lab"
  location = "westus2"
}

# Virtual Network within the resource group
resource "azurerm_virtual_network" "migration-lab-network" {
  name                = "migration-lab-network"
  resource_group_name = azurerm_resource_group.migration-lab-tf.name
  location            = azurerm_resource_group.migration-lab-tf.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.migration-lab-tf.name
  virtual_network_name = azurerm_virtual_network.migration-lab-network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-ssh-http"
  location            = azurerm_resource_group.migration-lab-tf.location
  resource_group_name = azurerm_resource_group.migration-lab-tf.name
}

resource "azurerm_network_security_rule" "SSH" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.migration-lab-tf.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "HTTP" {
  name                        = "HTTP"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.migration-lab-tf.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "ip" {
  name                = "migration-public-ip"
  location            = azurerm_resource_group.migration-lab-tf.location
  resource_group_name = azurerm_resource_group.migration-lab-tf.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "migration-nic"
  location            = azurerm_resource_group.migration-lab-tf.location
  resource_group_name = azurerm_resource_group.migration-lab-tf.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }

}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "azure-migrated-vm"
  resource_group_name = azurerm_resource_group.migration-lab-tf.name
  location            = azurerm_resource_group.migration-lab-tf.location
  size                = "Standard_B1s"
  admin_username      = var.adminusername

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.adminusername
    public_key = file("~/.ssh/tutorials/ec2_azure_migration_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = filebase64("${path.module}/../scripts/cloud-config.yaml")
}

resource "azurerm_key_vault" "migration_kv" {
  name                = var.key_vault_name
  tenant_id           = var.tenant_id
  location            = azurerm_resource_group.migration-lab-tf.location
  resource_group_name = azurerm_resource_group.migration-lab-tf.name
  sku_name            = "standard"

}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "vault_admin" {
  key_vault_id = azurerm_key_vault.migration_kv.id
  tenant_id    = var.tenant_id
  object_id    = var.user_object_id

  key_permissions    = ["Get", "List", "Create", "Delete"]
  secret_permissions = ["Get", "List", "Set", "Delete"]
}

resource "azurerm_postgresql_flexible_server" "migration_db" {
  name                = "vndlovu-migration-db0"
  resource_group_name = azurerm_resource_group.migration-lab-tf.name
  location            = azurerm_resource_group.migration-lab-tf.location
  version             = "12"


  public_network_access_enabled = true

  administrator_login    = var.postgres_administrator_login
  administrator_password = var.postgres_administrator_password
  zone                   = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  # delegated_subnet_id = azurerm_subnet.public.id
  # private_dns_zone_id = null

  sku_name = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_database" "formdb" {
  name      = "formdb"
  server_id = azurerm_postgresql_flexible_server.migration_db.id
  collation = "en_US.utf8"
  charset   = "UTF8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}
