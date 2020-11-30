#!/usr/bin/env bash
set -e

export API_GATEWAY=$(cat tpl/${1}.json | jq -r ".api_gateway_subdomains.${2}")
export HOST=$(cat tpl/${1}.json | jq -r '.host')

cat <<EOF > api-traffic-management.yaml
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${HOST}-${2}-certificate
  namespace: istio-system
spec:
  secretName: ${HOST}-${2}-certificate
  issuerRef:
    name: ${HOST}-issuer
    kind: ClusterIssuer
  commonName: "$API_GATEWAY"
  dnsNames:
  - "$API_GATEWAY"
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: api-gateway-${2}
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    tls:
      httpRedirect: true
    hosts:
    - "$API_GATEWAY"
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: ${HOST}-${2}-certificate
    hosts:
    - "$API_GATEWAY"
EOF
kubectl apply -f api-traffic-management.yaml

sleep 10
