#!/usr/bin/env bash

export cluster=$1
if [[ $cluster == 'preview' ]]; then
  host='monitoring.devportal.name'
fi

if [[ $cluster == 'sandbox' ]]; then
  host="*.$cluster.devportal.name"
fi

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
        - "$host"
EOF
kubectl apply -f monitoring-traffic-management.yaml

sleep 10
