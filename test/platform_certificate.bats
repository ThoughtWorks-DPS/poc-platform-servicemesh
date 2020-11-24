#!/usr/bin/env bats

@test "validate clusterissuer is up and ready" {
  HOST="devportal.name"
  if [[ $CLUSTER == 'sandbox' ]]; then
    HOST="$CLUSTER.devportal.name"
  fi

  run bash -c "kubectl get clusterissuer $HOST-issuer -n cert-manager -o json | jq -r '.status.conditions[] | .type'"
  [[ ${output} =~ "Ready" ]]
}

@test "validate certificate successfully issued" {
  HOST="devportal.name"
  if [[ $CLUSTER == 'sandbox' ]]; then
    HOST="$CLUSTER.devportal.name"
  fi

  run bash -c "kubectl get certificates $HOST-certificate -n istio-system -o json | jq -r '.status.conditions[] | .type'"
  [[ ${output} =~ "Ready" ]]
}