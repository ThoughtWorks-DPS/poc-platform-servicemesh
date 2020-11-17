#!/usr/bin/env bats

@test "validate cert-manager pod status" {
  run bash -c "kubectl get pods -n cert-manager -o wide | grep 'cert-manager'"
  [[ "${output}" =~ "Running" ]]
}

@test "validate cluster issuer pod status" {
  run bash -c "kubectl get pods clusterissuer | grep 'devportal-staging'"
  [[ "${output}" =~ "True" ]]
}

@test "validate certificate pod status" {
  run bash -c "kubectl get pods certificate -n cert-manager | grep 'devportal-staging'"
  [[ "${output}" =~ "True" ]]
}
