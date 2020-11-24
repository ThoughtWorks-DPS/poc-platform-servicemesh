#!/usr/bin/env bash

export HOST=$(cat tpl/${1}.json | jq -r '.host')

cat <<EOF > monitoring-traffic-management.yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: monitoring-gateway
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
        - "*.${HOST}"
EOF
kubectl apply -f monitoring-traffic-management.yaml

sleep 10
