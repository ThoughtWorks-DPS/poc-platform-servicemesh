#!/usr/bin/env bash
set -e

export AWS_ACCOUNT_ID=$(secrethub read vapoc/platform/svc/aws/aws-account-id)
export EMAIL=$(secrethub read vapoc/platform/svc/gmail/username)

aws sts assume-role --output json --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/DPSTerraformRole --role-session-name deploy-cert-manager-session >credentials
export AWS_ACCESS_KEY_ID=$(cat credentials | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(cat credentials | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(cat credentials | jq -r ".Credentials.SessionToken")
export AWS_DEFAULT_REGION=us-west-2
export host=devportal.name

export HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name $host | jq -r --arg DNS $host '.HostedZones[] | select( .Name | startswith($DNS)) | .Id')

cat <<EOF >certificate_configuration.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: devportal-staging
spec:
  acme:
    email: $EMAIL
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: devportal-staging-secret
    solvers:
    - selector:
        dnsZones:
          - "devportal.name"
      dns01:
        route53:
          region: $AWS_DEFAULT_REGION
          hostedZoneID: $HOSTED_ZONE_ID
          role: arn:aws:iam::${AWS_ACCOUNT_ID}:role/${1}-cert-manager
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: devportal-certificate
  namespace: cert-manager
spec:
  secretName: devportal-certificate-secret
  issuerRef:
    name: devportal-staging
    kind: ClusterIssuer
  dnsNames:
  - '*.devportal.name'
  - devportal.name
---
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: cert-manager
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${AWS_ACCOUNT_ID}:role/${1}-cert-manager
EOF

kubectl apply -f certificate_configuration.yaml

sleep 10