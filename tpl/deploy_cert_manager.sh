#!/usr/bin/env bash
#
# parameters
# $1 = cluster config to use

export CERT_MANAGER_VERSION=$(cat tpl/${1}.json | jq -r '.cert_manager_version')
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v${CERT_MANAGER_VERSION}/cert-manager.yaml
kubectl annotate serviceaccount cert-manager -n cert-manager eks.amazonaws.com/role-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/${1}-cert-manager