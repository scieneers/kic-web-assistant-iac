#!/usr/bin/env bash
set -euo pipefail

# Mirrors the Redis sidecar image into this project's Azure Container Registry,
# analogous to refresh-langfuse-image.sh. The sitecontainer previously pulled
# redis/redis-stack-server anonymously from Docker Hub directly, which is
# subject to Docker Hub's anonymous pull-rate limits — a suspected cause of
# the sidecar repeatedly failing to (re)start during an App Service crash
# loop. Re-run this whenever the pinned tag below is bumped.

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <env>  (e.g. dev, prod)" >&2
  exit 1
fi

ENV="$1"
ACR_NAME="kicacr${ENV}"
IMAGE_TAG="7.4.0-v6"
SOURCE_IMAGE="docker.io/redis/redis-stack-server:${IMAGE_TAG}"
TARGET_TAG="redis-stack-server:${IMAGE_TAG}"

echo "Importing ${SOURCE_IMAGE} into ${ACR_NAME} as ${TARGET_TAG}..."

az acr import \
  --name "${ACR_NAME}" \
  --source "${SOURCE_IMAGE}" \
  --image "${TARGET_TAG}" \
  --force

echo "Done."
