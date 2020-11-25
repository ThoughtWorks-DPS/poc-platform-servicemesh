#!/usr/bin/env bash
set -e

export API_GATEWAY=$(cat tpl/${1}.json | jq -r ".api_gateway_subdomains.${2}")
export HOST=$(cat tpl/${1}.json | jq -r '.host')

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
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: ${HOST}-certificate
    hosts:
    - "$API_GATEWAY"
EOF
kubectl apply -f api-traffic-management.yaml

sleep 10
