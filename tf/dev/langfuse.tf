resource "random_password" "postgres" {
  length  = 32
  special = true
  override_special = "$-_.+!*'()"
}

module "key_vault_postgres" {
  source       = "./modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.kv.id
  secrets = {
    POSTGRES_PASSWORD : random_password.postgres.result
  }
}

resource "azurerm_postgresql_flexible_server" "this" {
  lifecycle {
    #see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server
    ignore_changes = [high_availability[0].standby_availability_zone, zone]
  }

  name                = "${local.resource_prefix}-postgres-${local.environment}"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  administrator_login = "postgres"
  # TODO change
  administrator_password = module.key_vault_postgres.secrets.POSTGRES_PASSWORD
  create_mode            = "Default"
  storage_mb             = 32768
  storage_tier           = "P4"
  sku_name               = "B_Standard_B1ms"
  version                = 16

  authentication {
    password_auth_enabled = true
  }

  delegated_subnet_id = azurerm_subnet.postgres.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id
}

resource "azurerm_postgresql_flexible_server_database" "langfuse" {
  name      = "langfuse"
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "utf8"

  # prevent the possibility of accidental data loss
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "azurerm_linux_web_app" "langfuse" {
  # programmatically deployment of secrets not implemented yet #https://github.com/langfuse/langfuse/issues/517
  resource_group_name           = azurerm_resource_group.kic_web_assistant_rg.name
  name                          = "${local.resource_prefix}-langfuse-${local.environment}"
  location                      = local.region
  service_plan_id               = azurerm_service_plan.streamlit_service_plan.id
  https_only                    = true
  client_affinity_enabled       = false
  virtual_network_subnet_id     = azurerm_subnet.default.id
  public_network_access_enabled = true

  site_config {
    always_on = true
    application_stack {
      docker_image_name   = "langfuse:2.65.1"
      docker_registry_url = "https://ghcr.io/langfuse"
    }
    ftps_state = "FtpsOnly"
  }

  app_settings = {
    DATABASE_HOST     = azurerm_postgresql_flexible_server.this.fqdn
    DATABASE_NAME     = azurerm_postgresql_flexible_server_database.langfuse.name
    DATABASE_PASSWORD = azurerm_postgresql_flexible_server.this.administrator_password
    DATABASE_USERNAME = azurerm_postgresql_flexible_server.this.administrator_login
    NEXTAUTH_SECRET   = "mysecret"
    SALT              = "mysalt"
    NEXTAUTH_URL      = "https://${local.resource_prefix}-langfuse-${local.environment}.azurewebsites.net"
    TELEMETRY_ENABLED = false
    # azure sso
    LANGFUSE_DEFAULT_PROJECT_ID   = "${local.resource_prefix}"
    LANGFUSE_DEFAULT_PROJECT_ROLE = "ADMIN"
    AUTH_AZURE_AD_CLIENT_ID           = data.sops_file.secrets.data["AD_APP_ID"]
    AUTH_AZURE_AD_CLIENT_SECRET       = data.sops_file.secrets.data["AD_APP_SECRET_LANGFUSE"]
    AUTH_AZURE_AD_TENANT_ID           = data.azurerm_client_config.current.tenant_id
    AUTH_DISABLE_USERNAME_PASSWORD    = true
    AUTH_AZURE_ALLOW_ACCOUNT_LINKING  = true
    # the following two  values are currenlty ignored by langfuse,
    PORT = 80
  }

  # for enabling log stream of the web app
  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    application_logs {
      file_system_level = "Warning"
    }
    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 25
      }
    }
  }
}

module "key_vault_langfuse_host" {
  source       = "./modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.kv.id
  secrets = {
    LANGFUSE_HOST : "https://${azurerm_linux_web_app.langfuse.name}.azurewebsites.net"
  }
}

resource "azurerm_virtual_network" "this" {
  name                = "${local.resource_prefix}-vnet-${local.environment}"
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default" {
  name                 = "${local.resource_prefix}-subnet-default"
  resource_group_name  = azurerm_resource_group.kic_web_assistant_rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/26"]

  delegation {
    name = "delegation-webapp"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  service_endpoints = ["Microsoft.Sql", "Microsoft.CognitiveServices", "Microsoft.Web", "Microsoft.Storage"]
}

resource "azurerm_subnet" "postgres" {
  name                 = "${local.resource_prefix}-subnet-postgre"
  resource_group_name  = azurerm_resource_group.kic_web_assistant_rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/26"]

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

resource "azurerm_private_dns_zone" "postgres" {
  name                = "private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "postgressVnetDNSZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.this.id
  resource_group_name   = azurerm_resource_group.kic_web_assistant_rg.name
  depends_on            = [azurerm_subnet.postgres]
}