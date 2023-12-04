#!/bin/sh

VERSION="1.0.2"

set -e

helm repo add nginx-stable https://helm.nginx.com/stable && \
helm repo update && \
helm upgrade nginx-ingress nginx-stable/nginx-ingress \
    --namespace nginx-ingress \
    --create-namespace \
    --install \
    --version ${VERSION}
