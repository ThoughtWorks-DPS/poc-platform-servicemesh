#!/usr/bin/env bats

@test "evaluate istio ingressgateway service status" {
  run bash -c "kubectl get svc -n istio-system"
  [[ "${output}" =~ "istio-ingressgateway" ]]
  [[ "${output}" =~ "LoadBalancer" ]]
  [[ "${output}" =~ "us-west-2.elb.amazonaws.com" ]]
}

@test "evaluate external-dns status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'external-dns'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate istio ingressgateway pod status" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'istio-ingressgateway'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate istio istiod pod status" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'istiod'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate grafana pod status" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'grafana'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate prometheus pod status" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'prometheus'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate jaeger pod status" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'jaeger'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate kiali pod status" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'kiali'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate api gateway existence" {
  run bash -c "kubectl get gateway -n di-dev -o wide"
  [[ "${output}" =~ "api-gateway" ]]

  run bash -c "kubectl get gateway -n di-staging -o wide"
  [[ "${output}" =~ "api-gateway" ]]
}

@test "evaluate api virtual service existence for dev" {
  run bash -c "kubectl get virtualservice -n di-dev | grep 'api-virtual-service'"
  if [[ $CLUSTER == 'sandbox' ]]; then
    [[ "${output}" =~ "["dev.sandbox.devportal.com"]" ]]
  elif [[ $CLUSTER == 'preview' ]]; then
    [[ "${output}" =~ "["dev.devportal.com"]" ]]
  fi
}

@test "evaluate api virtual service existence for staging" {
  run bash -c "kubectl get virtualservice -n di-staging | grep 'api-virtual-service'"
  if [[ $CLUSTER == 'sandbox' ]]; then
    [[ "${output}" =~ "["api.sandbox.devportal.com"]" ]]
  elif [[ $CLUSTER == 'preview' ]]; then
    [[ "${output}" =~ "["api.devportal.com"]" ]]
  fi
}
