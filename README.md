# poc-platform-servicemesh

Starting point for istio servicemesh.

- Deploys Istio Operator
- Installs istio using operator, default profile plus:
- - distroless images
- - meshConfig.accessLogFile: "/dev/stdout"
- - meshConfig.accessLogEncoding: "JSON" 
- - ingressgateway enabled, for resource limit configuration 
