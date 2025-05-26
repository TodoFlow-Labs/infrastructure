# infrastructure

![Diag](./diag.png)

## Install MicroK8s on your server
### Setup test ubuntu server using terraform and libvirt
```bash
make terraform-init
make terraform-apply
```

### Install Sealed Secrets controller on Kubernetes cluster
```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.29.0/controller.yaml
```

## Create secrets
### Install kubeseal locally
```bash
brew install kubeseal
```

### Create Sealed Secret for Postgres, use your password instead of the 'pass'
```bash
kubectl create secret generic postgres-secret \
  --from-literal=username=postgres \
  --from-literal=password=pass  \
  --from-literal=postgres-password=pass  \
  --from-literal=database=todos \
  --namespace=db \
  --dry-run=client -o yaml | kubeseal --format yaml > k8s/apps/secrets/postgres-sealedsecret.yaml
```

### Create Sealed Secret for Grafana, use your password instead of the 'pass'
```bash
kubectl create secret generic grafana-secret \
  --from-literal=admin-user=admin \
  --from-literal=admin-password=pass  \
  --namespace=monitoring \
  --dry-run=client -o yaml | kubeseal --format yaml > k8s/apps/secrets/grafana-sealedsecret.yaml
```

### Create Sealed Secret for Todoflow, use your password instead of the 'pass'. Use supabase key and url from supabase project for Auth.
```bash
kubectl create secret generic todoflow-secret \
  --from-literal=nats-url=nats://nats.messaging.svc.cluster.local:4222 \
  --from-literal=database-url=postgres://postgres:pass@postgres.db.svc.cluster.local:5432/todos?sslmode=disable \
  --from-literal=supabase-api-key=ey... \
  --from-literal=supabase-url=https://...supabase.co \
  --namespace=todoflow \
  --dry-run=client -o yaml | kubeseal --format yaml > k8s/helm/todoflow/templates/sealedsecret.yaml
```


## Install ArgoCD via Helm
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade -i argocd argo/argo-cd \
  -n argocd \
  --create-namespace \
  -f k8s/helm/argocd/values.yaml
```

### Get default password for ArgoCD
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Change password for ArgoCD
  https://argo-cd.readthedocs.io/en/stable/getting_started


### Apply infra-root
```bash
kubectl apply -f k8s/apps/infra-root.yaml
```

### Reach ArgoCD UI
```argocd.local``` must be added to you DNS/hosts points to ip address of k8s server's loadbalancer
```bash
http://argocd.local
```

### Reach Grafana UI
```grafana.local``` must be added to you DNS/hosts points to ip address of k8s server's loadbalancer
```bash
http://grafana.local
```

### Reach Todoflow UI
```todoflow.local``` (or whatever is set at values.yaml) must be added to you DNS/hosts points to ip address of k8s server's loadbalancer
```bash
http://todoflow.local
```

## API todoflow
### GET /todos, GET /todos/:id. GET /todos?q=<search word>&s=<size>&page=<page_number>
```bash
http://todoflow.local/todos
```
### POST /todos
```bash
http://todoflow.local/todos
```
### PUT /todos/:id
```bash
http://todoflow.local/todos/:id
```
### DELETE /todos/:id
```bash
http://todoflow.local/todos/:id
```
### SSE events updates
```bash
http://todoflow.local/events
```
