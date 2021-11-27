# HELM chart

Create a tar.gz archive from this folder

```
helm install k8-calc k8-calc.tar.gz
helm uninstall k8-calc k8-calc.tar.gz

# change values
kubectl edit configmap calculateme-configmap
```
