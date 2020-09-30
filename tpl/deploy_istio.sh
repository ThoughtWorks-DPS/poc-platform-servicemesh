#!/usr/bin/env bash
#
# parameters
#
# $1 = cluster config to use

export ISTIO_VERSION=$(cat tpl/${1}.json | jq -r '.istio_version')
export KIALI_VERSION=$(cat tpl/${1}.json | jq -r '.kiali_version')
export DEFAULT_LIMITS_CPU=$(cat tpl/${1}.json | jq -r '.default_limits_cpu')
export DEFAULT_LIMITS_MEMORY=$(cat tpl/${1}.json | jq -r '.default_limits_memory')

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION >> sh -

cat <<EOF > istio-deploy-values.yaml
---
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: istiocontrolplane
spec:
  profile: default
  tag: ${ISTIO_VERSION}-distroless
  meshConfig.accessLogFile: "/dev/stdout"
  meshConfig.accessLogEncoding: "JSON"
  components:
    ingressGateways:
    - enabled: true
      k8s:
        resources:
          limits:
            cpu: ${DEFAULT_LIMITS_CPU}
            memory: ${DEFAULT_LIMITS_MEMORY}
          requests:
            cpu: 100m
            memory: 128Mi
  values:
    kiali:
      createDemoSecret: true
      tag: v${KIALI_VERSION}
EOF

istioctl operator init
kubectl create ns istio-system
cat istio-deploy-values.yaml | kubectl apply -f - 
sleep 20
