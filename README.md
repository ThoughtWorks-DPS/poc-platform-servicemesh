# poc-platform-servicemesh

Starting point for istio servicemesh.

- Deploys Istio using istioctl deploy with manifest overlay
    - distroless images
    - meshConfig.accessLogFile: "/dev/stdout"
    - meshConfig.accessLogEncoding: "JSON" 
    - ingressgateway enabled
    - prometheus, grafana, jaeger, kiali have quickstart installs, not production ready, only proxy access


## to access UIs

```
$ istioctl dashboard controlz <pod-name[.namespace]>
$ istioctl dashboard envoy <pod-name[.namespace]>
$ istioctl dashboard prometheus
$ istioctl dashboard grafana
$ istioctl dashboard jaeger
$ istioctl dashboard kiali
```

## setting up https for your service

In order to leverage the the https / http redirect settings in the api-gateway, the user must set up their VirtualService (in the respective repository) to `istio-system/api-gateway-<environment>`

See example below:
```
virtualService:
  host: dev.devportal.name
  gateway: istio-system/api-gateway-dev
```
