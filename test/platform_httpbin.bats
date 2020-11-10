#!/usr/bin/env bats

@test "validate httpbin pod status" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'grafana'"
  [[ "${output}" =~ "Running" ]]
}

@test "validate httpbin is accessible through gateway" {
  HOST="http://httpbin.$CLUSTER.devportal.name"
  if [[ $CLUSTER == 'preview' ]]; then
    HOST="http://httpbin.devportal.com/"
  fi

  run bash -c "curl -s -o /dev/null -w "%{http_code}" $HOST/get"
  [[ ${output} =~ "200" ]]
}