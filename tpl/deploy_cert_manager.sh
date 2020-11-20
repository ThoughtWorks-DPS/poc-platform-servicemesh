#!/usr/bin/env bash
#
# parameters
# $1 = cluster config to use

export CERT_MANAGER_VERSION=$(cat tpl/${1}.json | jq -r '.cert_manager_version')

kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --version v${CERT_MANAGER_VERSION} --set installCRDs=true