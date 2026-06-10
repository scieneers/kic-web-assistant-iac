resource "azurerm_search_service" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  replica_count   = var.replica_count
  partition_count = var.partition_count

  public_network_access_enabled = var.public_network_access_enabled
  local_authentication_enabled  = var.local_authentication_enabled
  # authentication_failure_mode may only be set while key-based auth is allowed
  authentication_failure_mode = var.local_authentication_enabled ? "http403" : null
  network_rule_bypass_option  = var.network_rule_bypass_option
  # allowed_ips only takes effect when the public endpoint is enabled
  allowed_ips         = var.public_network_access_enabled ? var.allowed_ips : []
  semantic_search_sku = var.semantic_search_sku

  identity {
    type = "SystemAssigned"
  }
}

#########################################
# Private networking
#########################################

resource "azurerm_private_dns_zone" "search" {
  name                = "privatelink.search.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "search" {
  name                  = "${var.name}-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.search.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "search" {
  name                = "${var.name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_search_service.this.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "search-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.search.id]
  }
}
