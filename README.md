# infrastructure

## Install MicroK8s on your server
```bash
sudo snap install microk8s --classic --channel=1.32
sudo usermod -a -G microk8s $USER
newgrp microk8s
microk8s status --wait-ready
```
### Enable Addons
```bash
microk8s enable dns helm helm3 hostpath-storage community linkerd
```

### Install loadbalancer
```bash
microk8s enable metallb
```
provide the list of ip address for loadbalancer.

### Collect microK8s config file
```bash
microk8s config > ~/kubeconfig
```

## Local PC
### Copy config and activate
```bash
scp <user>@<k8s server>:~/kubeconfig ~/.kube/microk8s-todoflow-config
export KUBECONFIG=~/.kube/microk8s-todoflow-config
```


### Install Traefik
```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update

helm upgrade -i traefik traefik/traefik -n traefik --create-namespace  -f k8s/helm/traefik/values.yaml
```

### Install ArgoCD via Helm
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade -i argocd argo/argo-cd \
  -n argocd \
  --create-namespace \
  -f k8s/helm/argocd/values.yaml

kubectl apply -f k8s/infra-root.yaml

```

### Reach ArgoCD UI 
```argocd.local``` must be added to you DNS/hosts points to ip address of k8s server's loadbalancer
```bash
http://argocd.local
```


## Create secrets
### Install kubeseal
```bash
brew install kubeseal
```

### Install Sealed Secrets controller
```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.29.0/controller.yaml
```

### Sealed Secret for Postgres
kubectl create secret generic postgres-secret \
  --from-literal=username=<name> \
  --from-literal=password=<pass>  \
  --from-literal=postgres-password=<pass> \
  --from-literal=database=<database-name> \
  --namespace=db \
  --dry-run=client -o yaml | kubeseal --format yaml > k8s/secrets/postgres-sealedsecret.yaml
