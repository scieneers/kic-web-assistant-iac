#!/usr/bin/env bash
set -euo pipefail

# One-time (per App Service instance) switch of the restapi app from the
# classic single-container model (linuxFxVersion "DOCKER|...") to App
# Service's sitecontainers/sidecar model (linuxFxVersion "SITECONTAINERS").
# Required for the Redis sidecar (scripts/deploy-sidecar.sh) to actually be
# scheduled — merely creating the sitecontainers ARM resource without this
# conversion leaves it inert, since the platform doesn't look at
# sitecontainers at all while the site is still in classic mode.
#
# Must be re-run any time this App Service is recreated (new environment,
# destroy/apply, disaster recovery), same as deploy-sidecar.sh. Terraform's
# azurerm_linux_web_app.restapi has `lifecycle { ignore_changes = [site_config, ...] }`
# so it won't fight this conversion back to "DOCKER|..." on later applies —
# but it also means Terraform never (re-)sets it, so this script must run at
# least once per environment.

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <env>  (e.g. dev, prod)" >&2
  exit 1
fi

ENV="$1"
RESOURCE_GROUP="kic-aichat-${ENV}"
APP_NAME="kic-restapi-${ENV}"

echo "Converting ${APP_NAME} in ${RESOURCE_GROUP} to sitecontainers mode..."

az webapp sitecontainers convert \
  --mode sitecontainers \
  --name "${APP_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --yes

echo "Done."
