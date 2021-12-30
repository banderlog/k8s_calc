# First in class complex post-AI blockchain-less nextgen advanced opensource end-to-end scalable multicloud SaaS smart product for high-loaded secure high performance computing systems

![globohomo art style](pic/header.png)

Powered with cutting edge *Foretold Termination™* technology (saves time on container unload), famous "less than 10 seconds" calculator on kubernetes.


## Prerequisites

+ [docker](https://docs.docker.com/engine/install/ubuntu/)
+ [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) (or any other k8s cluster)
+ [kubectl](https://kubernetes.io/docs/tasks/tools/)
+ [helm](https://helm.sh/docs/intro/install/)


## Installation and usage

**Installation example with kind:**
```
# cluster creation with `kind`
kind create cluster --config=./kind.yaml

# installation
helm install k8-calc k8-calc/

# verification -- should output "69"
curl http://localhost:30000/
```

**For different calculation *simply* do:**
+ run `kubectl edit configmap calculateme-configmap`
+ change `calculateme: 60+9` line, save and exit text editor
+ check `http://localhost:30000/`

**To remove everything:**
+ run `kind delete cluster`


## How it works

- There is env string variable `calculateme` defined in the ConfigMap
- A [busybox](https://busybox.net/) pod runs it through [bc](https://www.gnu.org/software/bc/), writes an answer to a file in the mounted volume and dies
- A [nginx](https://www.nginx.com/) pod mounts this file as index.html, so it is accessible via an HTTP request
- The [Reloader](https://github.com/stakater/Reloader) watches ConfigMap and restarts busybox pod if it changed
