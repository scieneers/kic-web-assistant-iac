#!/usr/bin/env bash
set -euo pipefail

# Deploys/updates the Redis sidecar container on the restapi App Service via
# the Microsoft.Web/sites/sitecontainers ARM API. The azurerm Terraform
# provider does not support App Service sidecar containers yet
# (hashicorp/terraform-provider-azurerm#25167), so this lives outside
# Terraform state and must be re-run any time the restapi App Service is
# recreated (new environment, destroy/apply, disaster recovery) — sitecontainers
# is a child resource of the site and does not survive its parent being replaced.
#
# The image is pulled from this project's ACR (see refresh-redis-image.sh)
# via the same user-assigned identity the main container already uses for
# registry pulls, not anonymously from Docker Hub — anonymous pulls are rate
# limited and were a suspected cause of the sidecar failing to restart during
# an App Service crash loop.

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <env>  (e.g. dev, prod)" >&2
  exit 1
fi

ENV="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFVARS_FILE="${SCRIPT_DIR}/../environments/${ENV}/${ENV}.tfvars"

if [[ ! -f "$TFVARS_FILE" ]]; then
  echo "tfvars file not found: $TFVARS_FILE" >&2
  exit 1
fi

SUBSCRIPTION_ID="$(grep -E '^subscription_id' "$TFVARS_FILE" | cut -d'"' -f2)"
RESOURCE_GROUP="kic-aichat-${ENV}"
APP_NAME="kic-restapi-${ENV}"
ACR_NAME="kicacr${ENV}"
IDENTITY_NAME="kic-uai-${ENV}"
SIDECAR_NAME="redis-checkpointer"
REDIS_IMAGE="${ACR_NAME}.azurecr.io/redis-stack-server:7.4.0-v6"
API_VERSION="2023-12-01"
IDENTITY_API_VERSION="2023-01-31"

IDENTITY_CLIENT_ID="$(az rest --method GET \
  --uri "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${IDENTITY_NAME}?api-version=${IDENTITY_API_VERSION}" \
  --query properties.clientId -o tsv)"

echo "Deploying sidecar '${SIDECAR_NAME}' (${REDIS_IMAGE}) to ${APP_NAME} in ${RESOURCE_GROUP}..."

az rest \
  --method PUT \
  --uri "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Web/sites/${APP_NAME}/sitecontainers/${SIDECAR_NAME}?api-version=${API_VERSION}" \
  --body "{
    \"properties\": {
      \"image\": \"${REDIS_IMAGE}\",
      \"isMain\": false,
      \"authType\": \"UserAssigned\",
      \"userManagedIdentityClientId\": \"${IDENTITY_CLIENT_ID}\"
    }
  }"

echo "Done."
