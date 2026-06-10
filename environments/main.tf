#########################################
# Resource Group (created in initial_setup)
#########################################

data "azurerm_resource_group" "main" {
  name = local.resource_group
}

#########################################
# Storage
#########################################

module "storage" {
  source              = "../modules/storage"
  name                = "${local.resource_prefix}sta${local.environment}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allowed_ip_ranges   = var.allowed_ip_ranges
  vnet_subnet_ids     = [azurerm_subnet.default.id, azurerm_subnet.container_apps.id]
}

#########################################
# Container Registry
#########################################

resource "azurerm_container_registry" "main" {
  name                = "${local.resource_prefix}acr${local.environment}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
}

#########################################
# Key Vault
#########################################

resource "azurerm_key_vault" "main" {
  name                       = "${local.resource_prefix}-keyvault-${local.environment}"
  location                   = local.region
  resource_group_name        = data.azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = [azurerm_subnet.default.id]
  }
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",
  ]
}

resource "azurerm_key_vault_access_policy" "admin_group" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.admin_group_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",
  ]
}

resource "azurerm_key_vault_access_policy" "uai" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.main.principal_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]
}

module "key_vault_secrets_sops" {
  source       = "../modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.main.id
  secrets      = nonsensitive(data.sops_file.secrets.data)
}

#########################################
# OpenAI
#########################################

module "openai" {
  source              = "../modules/openai"
  name                = "${local.resource_prefix}-aoai-${local.environment}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = "Germany West Central"

  model_deployments = [
    {
      name          = "gpt-5.4"
      model_name    = "gpt-5.4"
      model_version = "2026-03-05"
      sku_name      = "DataZoneStandard"
      capacity      = 670
    },
    {
      name          = "text-embedding-3-large"
      model_name    = "text-embedding-3-large"
      sku_name      = "DataZoneStandard"
      model_version = "1"
      capacity      = 2000
    }
  ]
}

module "key_vault_llms" {
  source       = "../modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.main.id
  secrets = {
    AZURE_OPENAI_URL                 = module.openai.endpoint
    AZURE_OPENAI_API_KEY             = module.openai.primary_access_key
    AZURE_OPENAI_GPT4_DEPLOYMENT     = module.openai.deployments["gpt-5.4"].name
    AZURE_OPENAI_GPT4_MODEL          = module.openai.deployments["gpt-5.4"].model_name
    AZURE_FALLBACK_MODEL             = module.openai.deployments["gpt-5.4"].model_name
    AZURE_FALLBACK_DEPLOYMENT        = module.openai.deployments["gpt-5.4"].name
    AZURE_OPENAI_EMBEDDER_DEPLOYMENT = module.openai.deployments["text-embedding-3-large"].name
    AZURE_OPENAI_EMBEDDER_MODEL      = module.openai.deployments["text-embedding-3-large"].model_name
  }
}

#########################################
# Monitoring
#########################################

module "monitoring" {
  source              = "../modules/monitoring"
  log_analytics_name  = "${local.resource_prefix}-log-${local.environment}"
  app_insights_name   = "ai-${local.environment}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
}

#########################################
# Qdrant
#########################################

resource "random_password" "qdrant_api_key" {
  length  = 64
  special = false
}

module "key_vault_qdrant_api_key" {
  source       = "../modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.main.id
  secrets = {
    QDRANT_API_KEY = random_password.qdrant_api_key.result
  }
}

resource "azurerm_container_app_environment" "qdrant" {
  name                     = "qdrant-environment"
  location                 = data.azurerm_resource_group.main.location
  resource_group_name      = data.azurerm_resource_group.main.name
  infrastructure_subnet_id = azurerm_subnet.container_apps.id

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

resource "azurerm_container_app_environment_storage" "qdrant" {
  name                         = "qdrant-storage"
  container_app_environment_id = azurerm_container_app_environment.qdrant.id
  account_name                 = module.storage.name
  share_name                   = module.storage.share_name
  access_key                   = module.storage.primary_access_key
  access_mode                  = "ReadWrite"
}

resource "azurerm_container_app" "qdrant" {
  name                         = "qdrant-app"
  container_app_environment_id = azurerm_container_app_environment.qdrant.id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  template {
    container {
      name   = "qdrant"
      image  = "${azurerm_container_registry.main.login_server}/qdrant/qdrant:${var.qdrant_image_tag}"
      cpu    = 4.0
      memory = "8Gi"

      env {
        name  = "QDRANT__SERVICE__API_KEY"
        value = module.key_vault_qdrant_api_key.secrets["QDRANT_API_KEY"]
      }

      volume_mounts {
        name = "qdrant-data"
        path = "/qdrant/storage"
      }

      volume_mounts {
        name     = "qdrant-data"
        path     = "/qdrant/snapshots"
        sub_path = "snapshots"
      }
    }

    volume {
      name         = "qdrant-data"
      storage_name = azurerm_container_app_environment_storage.qdrant.name
      storage_type = "AzureFile"
    }

    min_replicas = 1
    max_replicas = 1
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.main.id
  }

  ingress {
    external_enabled = true
    target_port      = 6333
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

module "key_vault_qdrant_url" {
  source       = "../modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.main.id
  secrets = {
    QDRANT_URL = "https://${azurerm_container_app.qdrant.ingress[0].fqdn}"
  }
}

#########################################
# Azure AI Search
#########################################

module "ai_search" {
  source              = "../modules/ai_search"
  name                = "${local.resource_prefix}-search-${local.environment}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  sku                 = var.search_sku
  semantic_search_sku = var.search_semantic_sku

  # RBAC-only: no API keys. Apps authenticate via managed identity, developers via `az login`.
  local_authentication_enabled = false

  # Apps reach the service privately through the endpoint in the VNet. Developers reach it over
  # the public endpoint, restricted to allowed_ip_ranges (a valid Entra token is still required).
  public_network_access_enabled = true
  allowed_ips                   = var.allowed_ip_ranges

  vnet_id                    = azurerm_virtual_network.main.id
  private_endpoint_subnet_id = azurerm_subnet.private_endpoints.id
}

module "key_vault_ai_search" {
  source       = "../modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.main.id
  secrets = {
    AZURE_SEARCH_ENDPOINT = module.ai_search.endpoint
  }
}

#########################################
# PostgreSQL + Langfuse
#########################################

resource "random_password" "postgres" {
  length           = 32
  special          = true
  override_special = "$-_.+!*'()"
}

module "key_vault_postgres" {
  source       = "../modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.main.id
  secrets = {
    POSTGRES_PASSWORD = random_password.postgres.result
  }
}

resource "azurerm_postgresql_flexible_server" "main" {
  lifecycle {
    # see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server
    ignore_changes = [high_availability[0].standby_availability_zone, zone]
  }

  name                          = "${local.resource_prefix}-postgres-${local.environment}"
  resource_group_name           = data.azurerm_resource_group.main.name
  location                      = data.azurerm_resource_group.main.location
  administrator_login           = "postgres"
  administrator_password        = module.key_vault_postgres.secrets.POSTGRES_PASSWORD
  create_mode                   = "Default"
  storage_mb                    = 32768
  storage_tier                  = "P4"
  sku_name                      = "B_Standard_B1ms"
  version                       = 16
  public_network_access_enabled = false

  authentication {
    password_auth_enabled = true
  }

  delegated_subnet_id = azurerm_subnet.postgres.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id
}

resource "azurerm_postgresql_flexible_server_database" "langfuse" {
  name      = "langfuse"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_linux_web_app" "langfuse" {
  resource_group_name             = data.azurerm_resource_group.main.name
  name                            = "${local.resource_prefix}-langfuse-${local.environment}"
  location                        = local.region
  service_plan_id                 = azurerm_service_plan.main.id
  https_only                      = true
  client_affinity_enabled         = false
  virtual_network_subnet_id       = azurerm_subnet.default.id
  public_network_access_enabled   = true
  key_vault_reference_identity_id = azurerm_user_assigned_identity.main.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  site_config {
    always_on                                     = true
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.main.client_id
    application_stack {
      docker_image_name   = "langfuse:2"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
    ftps_state = "FtpsOnly"
  }

  app_settings = {
    DATABASE_HOST                    = azurerm_postgresql_flexible_server.main.fqdn
    DATABASE_NAME                    = azurerm_postgresql_flexible_server_database.langfuse.name
    DATABASE_PASSWORD                = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=POSTGRES-PASSWORD)"
    DATABASE_USERNAME                = azurerm_postgresql_flexible_server.main.administrator_login
    NEXTAUTH_SECRET                  = "mysecret"
    SALT                             = "mysalt"
    NEXTAUTH_URL                     = "https://${local.resource_prefix}-langfuse-${local.environment}.azurewebsites.net"
    TELEMETRY_ENABLED                = false
    LANGFUSE_DEFAULT_PROJECT_ID      = local.resource_prefix
    LANGFUSE_DEFAULT_PROJECT_ROLE    = "ADMIN"
    AUTH_AZURE_AD_CLIENT_ID          = data.sops_file.secrets.data["AD_APP_ID"]
    AUTH_AZURE_AD_CLIENT_SECRET      = data.sops_file.secrets.data["AD_APP_SECRET_LANGFUSE"]
    AUTH_AZURE_AD_TENANT_ID          = data.azurerm_client_config.current.tenant_id
    AUTH_DISABLE_USERNAME_PASSWORD   = true
    AUTH_AZURE_ALLOW_ACCOUNT_LINKING = true
    PORT                             = 80
  }

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

module "key_vault_langfuse" {
  source       = "../modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.main.id
  secrets = {
    LANGFUSE_HOST = "https://${azurerm_linux_web_app.langfuse.name}.azurewebsites.net"
  }
}

#########################################
# App Service Plan
#########################################

resource "azurerm_service_plan" "main" {
  name                = "${local.resource_prefix}asp${local.environment}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku
}

#########################################
# REST API
#########################################

resource "random_password" "restapi_key_moodle" {
  length           = 32
  special          = true
  override_special = "$-_.+!*()"
}

resource "random_password" "restapi_key_scieneers" {
  length           = 32
  special          = true
  override_special = "$-_.+!*()"
}

resource "random_password" "restapi_key_drupal" {
  length           = 32
  special          = true
  override_special = "$-_.+!*()"
}

module "key_vault_restapi" {
  source       = "../modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.main.id
  secrets = {
    REST_API_KEYS = "['moodle-${random_password.restapi_key_moodle.result}', 'scieneers-${random_password.restapi_key_scieneers.result}', 'drupal-${random_password.restapi_key_drupal.result}']"
    ENVIRONMENT   = upper(local.environment)
  }
}

resource "azurerm_linux_web_app" "restapi" {
  name                            = "kic-restapi-${local.environment}"
  resource_group_name             = data.azurerm_resource_group.main.name
  location                        = data.azurerm_resource_group.main.location
  service_plan_id                 = azurerm_service_plan.main.id
  virtual_network_subnet_id       = azurerm_subnet.default.id
  key_vault_reference_identity_id = azurerm_user_assigned_identity.main.id

  app_settings = {
    KEY_VAULT_NAME                        = azurerm_key_vault.main.name
    AZURE_CLIENT_ID                       = azurerm_user_assigned_identity.main.client_id
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = false
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.monitoring.app_insights_connection_string
    LANGFUSE_PUBLIC_KEY                   = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=LANGFUSE-PUBLIC-KEY)"
    LANGFUSE_SECRET_KEY                   = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=LANGFUSE-SECRET-KEY)"
    LANGFUSE_HOST                         = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=LANGFUSE-HOST)"
    QDRANT_API_KEY                        = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=QDRANT-API-KEY)"
    QDRANT_URL                            = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=QDRANT-URL)"
    AZURE_SEARCH_ENDPOINT                 = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=AZURE-SEARCH-ENDPOINT)"
    AZURE_SEARCH_INDEX                    = "aichat"
    ENVIRONMENT                           = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=ENVIRONMENT)"
  }

  site_config {
    vnet_route_all_enabled                        = true
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.main.client_id
    application_stack {
      docker_image_name   = "nginxdemos/hello:latest"
      docker_registry_url = "https://index.docker.io"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  https_only = true

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].docker_image_name,
      site_config[0].application_stack[0].docker_registry_url,
      tags,
      sticky_settings,
    ]
  }
}

#########################################
# Frontend (dev only)
#########################################

resource "azurerm_linux_web_app" "frontend" {
  count               = local.environment == "prod" ? 0 : 1
  name                = "kic-frontend-${local.environment}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  app_settings = {
    KEY_VAULT_NAME                      = azurerm_key_vault.main.name
    AZURE_CLIENT_ID                     = azurerm_user_assigned_identity.main.client_id
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }

  site_config {
    application_stack {
      docker_image_name   = "nginxdemos/hello:latest"
      docker_registry_url = "https://index.docker.io"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  https_only = true

  auth_settings_v2 {
    auth_enabled           = true
    default_provider       = "aad"
    runtime_version        = "~1"
    unauthenticated_action = "RedirectToLoginPage"
    active_directory_v2 {
      client_id                   = data.sops_file.secrets.data["AD_APP_ID"]
      login_parameters            = {}
      tenant_auth_endpoint        = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
      www_authentication_disabled = false
    }
    login {
      token_store_enabled = true
    }
  }
}

#########################################
# Loader Function App (dev + prod)
#########################################

resource "azurerm_linux_function_app" "loader" {
  name                          = "${local.resource_prefix}-dataloader-${local.environment}"
  resource_group_name           = data.azurerm_resource_group.main.name
  location                      = data.azurerm_resource_group.main.location
  storage_account_name          = module.storage.name
  service_plan_id               = azurerm_service_plan.main.id
  storage_uses_managed_identity = true
  functions_extension_version   = "~4"
  virtual_network_subnet_id     = azurerm_subnet.default.id

  app_settings = {
    ENVIRONMENT                           = local.environment == "prod" ? "PRODUCTION" : "DEV"
    KEY_VAULT_NAME                        = azurerm_key_vault.main.name
    AZURE_CLIENT_ID                       = azurerm_user_assigned_identity.main.client_id
    FUNCTIONS_WORKER_RUNTIME              = "python"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    AzureWebJobsFeatureFlags              = "EnableWorkerIndexing"
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.monitoring.app_insights_connection_string
    AzureWebJobsStorage__clientId         = azurerm_user_assigned_identity.main.client_id
    QDRANT_COLLECTION                     = "aichat"
    AZURE_SEARCH_ENDPOINT                 = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=AZURE-SEARCH-ENDPOINT)"
    AZURE_SEARCH_INDEX                    = "aichat"
    AUDIO_TRANSCRIPTION_ENABLED           = "false"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  site_config {
    always_on                                     = true
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.main.client_id
    vnet_route_all_enabled                        = true
    application_stack {
      docker {
        image_name   = "nginxdemos/hello"
        image_tag    = "latest"
        registry_url = "https://index.docker.io"
      }
    }
  }

  https_only = true

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].docker,
      tags,
      sticky_settings,
    ]
  }
}
