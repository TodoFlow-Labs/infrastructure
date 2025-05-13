# infrastructure

### Install MicroK8s
```bash
sudo snap install microk8s --classic --channel=1.32
sudo usermod -a -G microk8s $USER
newgrp microk8s
microk8s status --wait-ready
```
### Enable Addons
```bash
microk8s enable dns storage ingress helm helm3
```
<!-- ### Install ArgoCD via Helm
```bash
microk8s helm repo add argo https://argoproj.github.io/argo-helm
microk8s helm repo update

microk8s helm install argocd argo/argo-cd --namespace argocd --create-namespace

``` -->

### Expose ArgoCD UI 
```bash
microk8s kubectl port-forward svc/argocd-server -n argocd 8080:443
--create-namespace
```


### Add helm charts
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
