# First in class complex post-AI blockchain-less nextgen advanced opensource end-to-end scalable multicloud SaaS smart product for high-loaded secure high performance computing systems

![globohomo art style](pic/header.png)

Powered with cutting edge *Foretold Termination™* technology (saves time on container unload), famous "less than 10 seconds" calculator on kubernetes.


## Prerequisites

+ [docker](https://docs.docker.com/engine/install/ubuntu/)
+ [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) (or any other k8s cluster)
+ [kubectl](https://kubernetes.io/docs/tasks/tools/)
+ [helm](https://helm.sh/docs/intro/install/)


## Installation and usage

**kind cluster [with ingress preparation](https://kind.sigs.k8s.io/docs/user/ingress/#using-ingress):**
```
# cluster creation with `kind`
kind create cluster --config=./kind.yaml

# ingress NGINX controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# wait until is ready to process requests running
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

**k8-calc installation:**
```
# installation
helm install k8-calc k8-calc/

# verification -- should output "69"
curl localhost/k8_calc
```

**For different calculation *simply* do:**
+ run `kubectl edit configmap calculateme-configmap`
+ change `calculateme: 60+9` line, save and exit text editor
+ check `localhost/k8_calc`

**To remove everything:**
+ run `kind delete cluster`


## How it works

- There is env string variable `calculateme` defined in the ConfigMap
- A [busybox](https://busybox.net/) pod runs it through [bc](https://www.gnu.org/software/bc/), writes an answer to a file in the mounted volume and dies
- A [nginx](https://www.nginx.com/) pod mounts this file as index.html, so it is accessible via an HTTP request
- The [Reloader](https://github.com/stakater/Reloader) watches ConfigMap and restarts busybox pod if it changed
