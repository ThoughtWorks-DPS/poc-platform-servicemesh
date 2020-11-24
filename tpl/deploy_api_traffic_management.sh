#!/usr/bin/env bash
set -e

export API_GATEWAY_SUBDOMAIN=$(cat tpl/${1}.json | jq -r ".api_gateway_subdomains.${2}")

cat <<EOF > api-traffic-management.yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: api-gateway-${2}
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "$API_GATEWAY_SUBDOMAIN"
---
kind: VirtualService
 metadata:
  name: api-virtual-service-${2}
 spec:
  hosts:
  - "$API_GATEWAY_SUBDOMAIN"
  gateways:
  - api-gateway
  http:
    - match:
      - uri:
          prefix: /teams
      route:
      - destination:
          host: poc-va-api
          port:
            number: 5000
EOF
kubectl apply -f api-traffic-management.yaml -n ${2}

sleep 10