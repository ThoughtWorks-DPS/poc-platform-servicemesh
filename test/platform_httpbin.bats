#!/usr/bin/env bats

@test "validate httpbin pod status" {
  run bash -c "kubectl get pods -n httpbin -o wide"
  [[ "${output}" =~ "Running" ]]
}

@test "validate httpbin is accessible through gateway" {
  HOST="http://httpbin.devportal.name"
  ARGS=""
  if [[ $CLUSTER == 'sandbox' ]]; then
    HOST="https://httpbin.$CLUSTER.devportal.name/"
    ARGS="--insecure"
  fi

  run bash -c "curl -s -o /dev/null -w "%{http_code}" $HOST/get $ARGS"
  [[ ${output} =~ "200" ]]
}