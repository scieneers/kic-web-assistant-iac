#!/bin/sh

VERSION="4.7.1"

set -e

helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace kicwa \
    --create-namespace \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.replicaCount=2 \
    --set controller.ingressClassResource.name=nginx \
    --set service.beta.kubernetes.io/azure-dns-label-name=kicwa \
    --version $VERSION 
