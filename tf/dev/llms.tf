module "key_vault_llms" {
  source       = "./modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.kv.id
  secrets = {
    AZURE_OPENAI_URL : "https://${azurerm_cognitive_account.openai.name}.openai.azure.com/"
    AZURE_OPENAI_API_KEY : azurerm_cognitive_account.openai.primary_access_key

    AZURE_OPENAI_GPT4_DEPLOYMENT : azurerm_cognitive_deployment.gpt-4o.name
    AZURE_OPENAI_GPT4_MODEL : azurerm_cognitive_deployment.gpt-4o.model[0].name
    AZURE_OPENAI_EMBEDDER_DEPLOYMENT : azurerm_cognitive_deployment.ada-embedding.name
    AZURE_OPENAI_EMBEDDER_MODEL : azurerm_cognitive_deployment.ada-embedding.model[0].name

    AZURE_MISTRAL_URL : module.mistral_large.model_url
  }
}

resource "azurerm_cognitive_account" "openai" {
  name                       = "${local.resource_prefix}-aoai-${local.environment}"
  location                   = "Sweden Central"
  resource_group_name        = azurerm_resource_group.kic_web_assistant_rg.name
  kind                       = "OpenAI"
  sku_name                   = "S0"
  custom_subdomain_name      = "${local.resource_prefix}-aoai-${local.environment}"
  dynamic_throttling_enabled = false

  network_acls {
    default_action = "Allow"
    ip_rules       = []
  }

  provisioner "local-exec" {
    when = destroy
    # When recreating the resource, it takes azure more time than it reports to delete the resource. This would block the creation of the new resource.
    command = "sleep 60"
  }
}

resource "azurerm_cognitive_deployment" "gpt-4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  rai_policy_name      = "Microsoft.Default"

  model {
    name    = "gpt-4o"
    version = "2024-05-13"
    format  = "OpenAI"
  }

  scale {
    capacity = 150
    type     = "Standard"

  }
}

resource "azurerm_cognitive_deployment" "gpt-4" {
  name                 = "gpt-4"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  rai_policy_name      = "Microsoft.Default"

  model {
    name    = "gpt-4"
    version = "0613"
    format  = "OpenAI"
  }

  scale {
    capacity = 40
    type     = "Standard"

  }
}

resource "azurerm_cognitive_deployment" "ada-embedding" {
  name                 = "text-embedding-ada-002"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  rai_policy_name      = "Microsoft.Default"

  model {
    name    = "text-embedding-ada-002"
    version = "2"
    format  = "OpenAI"
  }

  scale {
    capacity = 150
    type     = "Standard"

  }
}

resource "azurerm_cognitive_deployment" "three-large-embedding" {
  name                 = "text-embedding-3-large"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  rai_policy_name      = "Microsoft.Default"

  model {
    name    = "text-embedding-3-large"
    version = "1"
    format  = "OpenAI"
  }

  scale {
    capacity = 150
    type     = "Standard"

  }
}

#########################################
# Application Insights
#########################################
resource "azurerm_application_insights" "ai" {
  name                = "ai-${local.environment}"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  application_type    = "web"
}

#########################################
# Azure AI Hub for Mistral
#########################################
module "mistral_ai_hub" {
  source                  = "./modules/ai_hub"
  environment_name        = "mistral-${local.environment}"
  location                = local.mistral_region
  resource_group_id       = azurerm_resource_group.kic_web_assistant_rg.id
  key_vault_id            = azurerm_key_vault.kv.id
  application_insights_id = azurerm_application_insights.ai.id
  storage_account_id      = azurerm_storage_account.kic_wa_sa.id
}

#########################################
# Azure AI Project for Mistral
#########################################
module "mistral_ai_project" {
  source            = "./modules/ai_project"
  environment_name  = "mis-${local.environment}"
  location          = local.mistral_region
  resource_group_id = azurerm_resource_group.kic_web_assistant_rg.id
  hub_id            = module.mistral_ai_hub.id
}

#########################################
# Azure AI Hub for Llama2
#########################################
module "llama_ai_hub" {
  source                  = "./modules/ai_hub"
  environment_name        = "llama-${local.environment}"
  location                = local.llama_region
  resource_group_id       = azurerm_resource_group.kic_web_assistant_rg.id
  key_vault_id            = azurerm_key_vault.kv.id
  application_insights_id = azurerm_application_insights.ai.id
  storage_account_id      = azurerm_storage_account.kic_wa_sa.id
}

#########################################
# Azure AI Project for Llama2
#########################################
module "llama_ai_project" {
  source            = "./modules/ai_project"
  environment_name  = "lla-${local.environment}"
  location          = local.llama_region
  resource_group_id = azurerm_resource_group.kic_web_assistant_rg.id
  hub_id            = module.llama_ai_hub.id
}

##########################################
# Model: Mistral large
##########################################
module "mistral_large" {
  source            = "./modules/ai_model_serverless"
  environment_name  = local.environment
  location          = local.mistral_region
  resource_group_id = azurerm_resource_group.kic_web_assistant_rg.id
  project_id        = module.mistral_ai_project.id
  model = {
    id                       = "azureml://registries/azureml-mistral/models/Mistral-large"
    name                     = "Mistral-large"
    marketplace_publisher_id = "000-000"
    marketplace_offer_id     = "mistral-ai-large-offer"
    marketplace_plan_id      = "mistral-large-2402-plan"
  }
}

#########################################
# Model: Meta-Llama-2-7B
#########################################
#module "Meta-Llama-2-7B" {
#  source = "./modules/ai_model_serverless"
# environment_name = local.environment
# location         = local.llama_region
# resource_group_id = azurerm_resource_group.kic_web_assistant_rg.id
#  project_id        = module.llama_ai_project.id
#  model = {
#    id = "azureml://registries/azureml-meta/models/Llama-2-7b-chat"
#    name = "Meta-Llama-2-7B-chat"
#    marketplace_publisher_id = "metagenai"
#    marketplace_offer_id = "meta-llama-2-7b-chat-offer"
#    marketplace_plan_id  = "meta-llama-2-7b-chat-plan"
#  }
#}