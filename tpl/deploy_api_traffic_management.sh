#!/usr/bin/env bash
set -e

export API_GATEWAY=$(cat tpl/${1}.json | jq -r ".api_gateway_subdomains.${2}")

cat <<EOF > api-traffic-management.yaml
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
    hosts:
    - "$API_GATEWAY"
EOF
kubectl apply -f api-traffic-management.yaml

sleep 10