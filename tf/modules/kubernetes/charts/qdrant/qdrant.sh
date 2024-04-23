#!/bin/sh

VERSION="0.8.4"

set -e

helm repo add qdrant https://qdrant.github.io/qdrant-helm && \
helm repo update && \
sops -d ./values.yaml | helm upgrade qdrant qdrant/qdrant \
    --namespace kicwa \
    --create-namespace \
    --install \
    -f - \
    --version "0.8.4"
