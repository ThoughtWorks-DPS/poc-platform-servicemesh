#!/usr/bin/env bash

cat <<EOF > api-traffic-management.yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: poc-va-api-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "$1.devportal.name"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: poc-va-api-virtual-service
spec:
  hosts:
  - "$1.devportal.name"
  gateways:
  - poc-va-api-gateway
  http:
    - match:
      - uri:
          prefix: /teams
      rewrite:
        uri: /
      route:
      - destination:
          host: poc-va-api
          port:
            number: 5000
EOF
kubectl apply -f api-traffic-management.yaml

sleep 10
