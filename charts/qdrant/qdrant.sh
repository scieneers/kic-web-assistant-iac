#!/bin/sh

VERSION="0.6.1"

set -e

helm repo add qdrant https://qdrant.github.io/qdrant-helm && \
helm repo update && \
helm upgrade qdrant qdrant/qdrant \
    --namespace qdrant \
    --create-namespace \
    --install \
    -f ./values.yaml \
    --version ${VERSION}
