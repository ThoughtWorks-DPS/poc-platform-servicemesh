#!/usr/bin/env bats

@test "evaluate api gateway existence" {
  run bash -c "kubectl get gateway -n di-dev -o wide"
  [[ "${output}" =~ "api-gateway" ]]

  run bash -c "kubectl get gateway -n di-staging -o wide"
  [[ "${output}" =~ "api-gateway" ]]
}

@test "evaluate api virtual service existence for dev" {
  run bash -c "kubectl get virtualservice -n di-dev | grep 'api-virtual-service'"
  if [[ $CLUSTER == 'sandbox' ]]; then
    [[ "${output}" =~ "["dev.sandbox.devportal.name"]" ]]
  elif [[ $CLUSTER == 'preview' ]]; then
    [[ "${output}" =~ "["dev.devportal.name"]" ]]
  fi
}

@test "evaluate api virtual service existence for staging" {
  run bash -c "kubectl get virtualservice -n di-staging | grep 'api-virtual-service'"
  if [[ $CLUSTER == 'sandbox' ]]; then
    [[ "${output}" =~ "["api.sandbox.devportal.name"]" ]]
  elif [[ $CLUSTER == 'preview' ]]; then
    [[ "${output}" =~ "["api.devportal.name"]" ]]
  fi
}