#!/bin/sh

VERSION="v1.13.2"

set -e

helm repo add jetstack https://charts.jetstack.io && \
helm repo update && \
helm upgrade cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --install \
  --version ${VERSION} \
  --set installCRDs=true