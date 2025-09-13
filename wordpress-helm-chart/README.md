# WordPress Helm Chart

Production-ready WordPress deployment with MySQL on Kubernetes.

## Features

- WordPress with persistent storage
- MySQL StatefulSet with persistent data
- ConfigMaps for PHP/MySQL configuration
- Secrets for credential management
- Security contexts and probes
- Automatic PVC cleanup on uninstall

## Requirements

- Kubernetes 1.19+
- Helm 3.x
- 1GB RAM minimum
- 2GB disk space

## Quick Start

```bash
# Install WordPress
helm install wordpress-demo .

# Get WordPress URL
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services wordpress-demo-wordpress) && export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}") && echo http://$NODE_IP:$NODE_PORT

# Or use minikube
minikube service wordpress-demo-wordpress --url
```

## Current Deployment Instructions

```bash
# 1. Navigate to chart directory
cd /Users/dtorun/Desktop/dogancan/wordpress-helm-chart

# 2. Install or upgrade
helm upgrade --install wordpress-demo .

# 3. Get access URL
minikube service wordpress-demo-wordpress --url

# 4. Check status
kubectl get pods
kubectl get svc
```

## Access Credentials

```bash
# WordPress admin (username: admin)
kubectl get secret wordpress-demo-secrets -o jsonpath="{.data.wordpress-admin-password}" | base64 -d

# MySQL root password
kubectl get secret wordpress-demo-mysql-secrets -o jsonpath="{.data.mysql-root-password}" | base64 -d
```

## Configuration

Key parameters in `values.yaml`:

```yaml
wordpress:
  replicaCount: 1
  image:
    repository: wordpress
    tag: 6.5-php8.3-apache
  config:
    debug: false
    memoryLimit: "256M"

mysql:
  image:
    repository: mysql
    tag: "8.0"
  config:
    maxConnections: 151
    innodbBufferPoolSize: "128M"

# Disable cleanup for production
cleanup:
  enabled: false
```

## Monitoring

```bash
# Check pods
kubectl get pods

# Check logs
kubectl logs -l "app.kubernetes.io/component=wordpress"
kubectl logs -l "app.kubernetes.io/component=mysql"

# Check services
kubectl get svc
```

## Upgrade & Scaling

```bash
# Upgrade
helm upgrade wordpress-demo .

# Scale WordPress
kubectl scale deployment wordpress-demo-wordpress --replicas=3
```

## Backup

```bash
# MySQL backup
kubectl exec wordpress-demo-mysql-0 -- mysqldump -u root -p<PASSWORD> wordpress > backup.sql

# WordPress files
kubectl exec -it deployment/wordpress-demo-wordpress -- tar czf - wp-content > files_backup.tar.gz
```

## Uninstall

```bash
# Uninstall (PVCs automatically cleaned up)
helm uninstall wordpress-demo

# For production (disable cleanup first)
helm upgrade wordpress-demo . --set cleanup.enabled=false
helm uninstall wordpress-demo
kubectl delete pvc --all  # Manual cleanup if needed
```

## File Structure

```
wordpress-helm-chart/
├── Chart.yaml
├── values.yaml
├── README.md
└── templates/
    ├── _helpers.tpl
    ├── cleanup-job.yaml
    ├── configmap.yaml
    ├── ingress.yaml
    ├── mysql-statefulset.yaml
    ├── pvc.yaml
    ├── rbac.yaml
    ├── secrets.yaml
    ├── serviceaccount.yaml
    ├── services.yaml
    └── wordpress-deployment.yaml
```

## License

MIT License