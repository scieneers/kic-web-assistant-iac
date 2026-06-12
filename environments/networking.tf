#########################################
# Networking
#########################################

resource "azurerm_virtual_network" "main" {
  name                = "${local.resource_prefix}-vnet-${local.environment}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default" {
  name                              = "${local.resource_prefix}-subnet-default"
  resource_group_name               = data.azurerm_resource_group.main.name
  virtual_network_name              = azurerm_virtual_network.main.name
  address_prefixes                  = ["10.0.1.0/26"]
  private_endpoint_network_policies = "Disabled"

  delegation {
    name = "delegation-webapp"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  service_endpoints = ["Microsoft.Sql", "Microsoft.CognitiveServices", "Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "postgres" {
  name                              = "${local.resource_prefix}-subnet-postgre"
  resource_group_name               = data.azurerm_resource_group.main.name
  virtual_network_name              = azurerm_virtual_network.main.name
  address_prefixes                  = ["10.0.2.0/26"]
  private_endpoint_network_policies = "Disabled"

  delegation {
    name = "delegation-postgres"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                              = "${local.resource_prefix}-subnet-pe"
  resource_group_name               = data.azurerm_resource_group.main.name
  virtual_network_name              = azurerm_virtual_network.main.name
  address_prefixes                  = ["10.0.3.0/26"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "private.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "postgressVnetDNSZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.main.id
  resource_group_name   = data.azurerm_resource_group.main.name
  depends_on            = [azurerm_subnet.postgres]
}
