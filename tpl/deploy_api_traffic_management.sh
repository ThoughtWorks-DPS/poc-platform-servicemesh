#!/usr/bin/env bash
set -e

export API_GATEWAY_DEV=$(cat tpl/${1}.json | jq -r ".api_gateway_subdomains.dev")
export API_GATEWAY_STAGING=$(cat tpl/${1}.json | jq -r ".api_gateway_subdomains.staging")

cat <<EOF > api-traffic-management.yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: api-gateway-dev
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "$API_GATEWAY_DEV"
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: api-gateway-staging
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "$API_GATEWAY_STAGING"
EOF
kubectl apply -f api-traffic-management.yaml

sleep 10