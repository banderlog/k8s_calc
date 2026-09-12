# First in class complex post-AI blockchain-less nextgen advanced opensource end-to-end scalable multicloud SaaS smart product for high-loaded secure high performance computing systems

![globohomo art style](pic/header.png)

Powered with cutting edge *Foretold Termination™* technology (saves time on container unload), famous "less than 10 seconds" calculator on kubernetes.


## Prerequisites

+ [docker](https://docs.docker.com/engine/install/ubuntu/)
+ [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) (or any other k8s cluster)
+ [kubectl](https://kubernetes.io/docs/tasks/tools/)
+ [helm](https://helm.sh/docs/intro/install/)


## Installation and usage

ingress-nginx is being phased out in favor of the [Gateway API](https://gateway-api.sigs.k8s.io/), so this chart routes traffic through a `Gateway`/`HTTPRoute` served by [NGINX Gateway Fabric](https://github.com/nginx/nginx-gateway-fabric) instead of an `Ingress`.

**kind cluster:**
```
# cluster creation with `kind`
kind create cluster --config=./kind.yaml
```

**Gateway API:**
```
# Gateway API CRDs
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.7.0" | kubectl apply -f -

# NGINX Gateway Fabric controller
# (pin to a chart version compatible with your cluster's k8s version --
#  2.7.0+ requires k8s >= 1.32, older clusters need <= 2.4.0)
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway

# wait until is ready to process requests running
kubectl wait --namespace nginx-gateway \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=nginx-gateway-fabric \
  --timeout=90s
```

**k8-calc installation:**
```
# installation
helm install k8-calc k8-calc/

# verification -- should output "69"
curl localhost/k8_calc
```

**For different calculation you have two options:**
1. re-deploy with new expression argument
    + `helm install k8-calc k8-calc/ --set expression=%your_expression%`
	+ check `localhost/k8_calc`
2. change ConfigMap inside current deployment
    + run `kubectl edit configmap calculateme-configmap`
    + change `calculateme: 60+9` line, save and exit text editor
	+ check `localhost/k8_calc`

**To remove everything:**
+ run `kind delete cluster`


## How it works

- There is env string variable `calculateme` defined in the ConfigMap
- A [busybox](https://busybox.net/) pod runs it through [bc](https://www.gnu.org/software/bc/), writes an answer to a file in the mounted volume and dies
- A [nginx](https://www.nginx.com/) pod mounts this file as index.html, so it is accessible via an HTTP request
- A `Gateway`/`HTTPRoute` pair routes `/k8_calc` to that pod through NGINX Gateway Fabric; a fixed NodePort (set via the `NginxProxy` resource) is what `kind.yaml`'s port mapping targets
- The [Reloader](https://github.com/stakater/Reloader) watches ConfigMap and restarts busybox pod if it changed
