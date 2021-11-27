# K8S as a separate configs

Do not do it: https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/

```
# run
kubectl apply -f $(echo *.yaml | tr " " ",")

# change values (?)
kubectl edit configmap calculateme-configmap

# change values (?)
kubectl edit deployment.apps bc

# get nodes info with ip
kubectl -n default get nodes -o wide
```
