#!/usr/bin/env bats

@test "evaluate api gateway existence" {
  run bash -c "kubectl get gateway -n istio-system -o wide | grep api-gateway-dev"
  [[ "${output}" =~ "api-gateway-dev" ]]

  run bash -c "kubectl get gateway -n istio-system -o wide | grep api-gateway-staging"
  [[ "${output}" =~ "api-gateway-staging" ]]
}