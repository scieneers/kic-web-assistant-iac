#!/bin/sh

VERSION="0.6.1"

set -e

helm repo add qdrant https://qdrant.github.io/qdrant-helm && \
helm repo update && \
sops -d ./values.yaml | helm upgrade qdrant qdrant/qdrant \
    --namespace qdrant \
    --create-namespace \
    --install \
    -f - \
    --version ${VERSION}
