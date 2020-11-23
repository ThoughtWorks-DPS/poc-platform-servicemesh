#!/usr/bin/env bash
set -e

export AWS_ACCOUNT_ID=$(secrethub read vapoc/platform/svc/aws/aws-account-id)
export EMAIL=$(secrethub read vapoc/platform/svc/gmail/username)

aws sts assume-role --output json --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/DPSTerraformRole --role-session-name deploy-cert-manager-session >credentials
export AWS_ACCESS_KEY_ID=$(cat credentials | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(cat credentials | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(cat credentials | jq -r ".Credentials.SessionToken")
export AWS_DEFAULT_REGION=us-west-2
export HOST=$(cat tpl/${1}.json | jq -r '.host')

export HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name $HOST | jq -r --arg DNS $HOST '.HostedZones[] | select( .Name | startswith($DNS)) | .Id')

export ISSUER_ENDPOINT=$(cat tpl/${1}.json | jq -r '.issuerEndpoint')

cat <<EOF >certificate_configuration.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${HOST}-issuer
spec:
  acme:
    email: $EMAIL
    server: $ISSUER_ENDPOINT
    privateKeySecretRef:
      name: ${HOST}-certificate
    solvers:
    - dns01:
        route53:
          region: $AWS_DEFAULT_REGION
          hostedZoneID: $HOSTED_ZONE_ID
      selector:
        dnsZones:
          - ${HOST}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${HOST}-certificate
  namespace: istio-system
spec:
  secretName: ${HOST}-certificate
  issuerRef:
    name: ${HOST}-issuer
    kind: ClusterIssuer
  commonName: httpbin.${HOST}
  dnsNames:
  - httpbin.${HOST}
EOF

kubectl apply -f certificate_configuration.yaml

sleep 10