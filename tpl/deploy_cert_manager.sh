#!/usr/bin/env bash
#
# parameters
# $1 = cluster config to use

export CERT_MANAGER_VERSION=$(cat tpl/${1}.json | jq -r '.cert_manager_version')
export AWS_ACCOUNT_ID=$(secrethub read vapoc/platform/svc/aws/aws-account-id)

cat <<EOF > cert-manager-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
EOF
kubectl apply -f cert-manager-namespace.yaml

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --version v${CERT_MANAGER_VERSION} --set installCRDs=true --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::${AWS_ACCOUNT_ID}:role/${1}-cert-manager -f tpl/values.cert_manager.yaml