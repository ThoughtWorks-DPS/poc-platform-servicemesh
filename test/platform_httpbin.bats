#!/usr/bin/env bats

@test "validate httpbin pod status" {
  run bash -c "kubectl get pods -n httpbin -o wide"
  [[ "${output}" =~ "Running" ]]
}

@test "validate httpbin is accessible through gateway" {
  HOST="https://httpbin.devportal.name"
  ARGS="--insecure"
  if [[ $CLUSTER == 'sandbox' ]]; then
    HOST="https://httpbin.$CLUSTER.devportal.name/"
  fi

  run bash -c "curl -s -o /dev/null -w "%{http_code}" $HOST/get $ARGS"
  [[ ${output} =~ "200" ]]
}

@test "validate httpbin protocol redirect" {
  HOST="http://httpbin.devportal.name"
  ARGS="--insecure"
  if [[ $CLUSTER == 'sandbox' ]]; then
    HOST="http://httpbin.$CLUSTER.devportal.name/"
  fi

  run bash -c "curl -s -o /dev/null -w "%{http_code}" $HOST/get $ARGS"
  [[ ${output} =~ "200" ]]
}