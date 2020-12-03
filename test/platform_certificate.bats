#!/usr/bin/env bats

# @test "validate clusterissuer is up and ready" {
#   HOST="devportal.name"
#   if [[ $CLUSTER == 'sandbox' ]]; then
#     HOST="$CLUSTER.devportal.name"
#   fi

#   run bash -c "kubectl get clusterissuer $HOST-issuer -n cert-manager -o json | jq -r '.status.conditions[] | select(.type=\"Ready\") | .status'"
#   [[ ${output} =~ "True" ]]
# }

# @test "validate certificate successfully issued" {
#   HOST="devportal.name"
#   if [[ $CLUSTER == 'sandbox' ]]; then
#     HOST="$CLUSTER.devportal.name"
#   fi

#   run bash -c "kubectl get certificates $HOST-certificate -n istio-system -o json | jq -r '.status.conditions[] | select(.type=\"Ready\") | .status'"
#   [[ ${output} =~ "True" ]]
# }

@test "validate certificate successfully renewed" {
  run bash -c "kubectl apply -f ./tpl/renew_certificate.yaml"
  run bash -c "kubectl get certificates test-certificate -n istio-system -o json | jq -r '.status.conditions[] | select(.type=\"Ready\") | .status'"
  run bash -c "sleep 120"
  run bash -c "kubectl get certificates test-certificate -n istio-system -o json | jq -r '.status.conditions[] | select(.type=\"Ready\") | .status'"
}