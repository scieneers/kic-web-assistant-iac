#!/usr/bin/env bash
set -euo pipefail

# Refreshes the "langfuse:2" image in this project's Azure Container Registry
# by re-importing the latest v2.x build of langfuse/langfuse from Docker Hub.
# The ACR mirror does not auto-update; re-run this whenever a newer
# patch/minor release within the v2 line is needed. Keep the target tag on
# the "2" major-version alias (not a specific minor/patch), per Langfuse's
# own self-hosting guidance, so the backend's `langfuse~=2.60.0` SDK
# constraint stays compatible (v2 SDK <-> v2 server; v3 is a breaking change).

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <env>  (e.g. dev, prod)" >&2
  exit 1
fi

ENV="$1"
ACR_NAME="kicacr${ENV}"
SOURCE_IMAGE="docker.io/langfuse/langfuse:2"
TARGET_TAG="langfuse:2"

echo "Importing ${SOURCE_IMAGE} into ${ACR_NAME} as ${TARGET_TAG}..."

az acr import \
  --name "${ACR_NAME}" \
  --source "${SOURCE_IMAGE}" \
  --image "${TARGET_TAG}" \
  --force

echo "Done."
