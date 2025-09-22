module "key_vault_llms" {
  source       = "./modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.kv.id
  secrets = {
    AZURE_OPENAI_URL : "https://swedencentral.api.cognitive.microsoft.com/"
    AZURE_OPENAI_API_KEY : module.openai.primary_access_key

    AZURE_OPENAI_GPT4_DEPLOYMENT : "gpt-4o"
    AZURE_OPENAI_GPT4_MODEL : "gpt-4o"
    AZURE_OPENAI_EMBEDDER_DEPLOYMENT : "text-embedding-3-large"
    AZURE_OPENAI_EMBEDDER_MODEL : "text-embedding-3-large"

  }
}

module "openai" {
  source                  = "./modules/openai"
  cognitive_account_name  = "kicaoai${var.environment_short}" // Name for standard OpenAI
  openai_location         = "Sweden Central"
  resource_group_name     = azurerm_resource_group.kic_web_assistant_rg.name
  openai_sku              = var.openai_sku
  openai_model_deployment = var.openai_model_deployment
}


#########################################
# Application Insights
#########################################
resource "azurerm_log_analytics_workspace" "this" {
  name                = "kic-law-${local.environment}"
  location            = local.region
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_application_insights" "ai" {
  name                = "ai-${local.environment}"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.this.id

}