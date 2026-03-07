# FastGateway Helm Chart

A Helm chart for deploying FastGateway - Kubernetes Gateway API Management Platform.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.0+
- PostgreSQL database
- Envoy Gateway installed in the cluster

## Installation

### 1. Create Required Secrets

Before installing the chart, create the required secrets in your namespace:

```bash
# Application secrets
kubectl create secret generic fastgateway-secrets \
  --from-literal=jwt-secret=$(openssl rand -base64 32) \
  --from-literal=encryption-key=$(openssl rand -base64 32) \
  --from-literal=admin-password=<your-admin-password> \
  -n <namespace>

# Database credentials
kubectl create secret generic fastgateway-database \
  --from-literal=username=<db-username> \
  --from-literal=password=<db-password> \
  --from-literal=database=<db-name> \
  -n <namespace>
```

### 2. Install the Chart

```bash
helm install fastgateway ./chart \
  --set secrets.existingSecret=fastgateway-secrets \
  --set database.existingSecret=fastgateway-database \
  --set database.host=<postgres-host> \
  -n <namespace>
```

### 3. Access the Application

```bash
# Port-forward frontend
kubectl port-forward svc/fastgateway-frontend 3001:3001 -n <namespace>

# Open http://localhost:3001
```

## Configuration

### Required Values

| Parameter | Description |
|-----------|-------------|
| `secrets.existingSecret` | Name of secret containing `jwt-secret`, `encryption-key`, `admin-password` |
| `database.existingSecret` | Name of secret containing `username`, `password`, `database` |
| `database.host` | PostgreSQL host |

### Backend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `backend.enabled` | Enable backend deployment | `true` |
| `backend.image.repository` | Backend image repository | `fastgateway/backend` |
| `backend.image.tag` | Backend image tag | `latest` |
| `backend.replicaCount` | Number of backend replicas | `1` |
| `backend.service.type` | Backend service type | `ClusterIP` |
| `backend.service.port` | Backend service port | `8081` |
| `backend.resources.limits.cpu` | CPU limit | `500m` |
| `backend.resources.limits.memory` | Memory limit | `512Mi` |
| `backend.resources.requests.cpu` | CPU request | `100m` |
| `backend.resources.requests.memory` | Memory request | `128Mi` |

### Frontend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `frontend.enabled` | Enable frontend deployment | `true` |
| `frontend.image.repository` | Frontend image repository | `fastgateway/frontend` |
| `frontend.image.tag` | Frontend image tag | `latest` |
| `frontend.replicaCount` | Number of frontend replicas | `1` |
| `frontend.service.type` | Frontend service type | `ClusterIP` |
| `frontend.service.port` | Frontend service port | `3001` |
| `frontend.resources.limits.cpu` | CPU limit | `200m` |
| `frontend.resources.limits.memory` | Memory limit | `256Mi` |
| `frontend.resources.requests.cpu` | CPU request | `50m` |
| `frontend.resources.requests.memory` | Memory request | `64Mi` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `database.host` | PostgreSQL host (required) | `""` |
| `database.port` | PostgreSQL port | `5432` |
| `database.existingSecret` | Secret name for database credentials (required) | `""` |

### Application Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.logLevel` | Log level (debug, info, warn, error) | `info` |
| `config.jwtExpiry` | JWT token expiry | `24h` |
| `config.refreshTokenExpiry` | Refresh token expiry | `168h` |
| `config.corsAllowedOrigins` | CORS allowed origins | `*` |
| `config.adminUsername` | Default admin username | `admin` |
| `config.adminEmail` | Default admin email | `admin@fastgateway.local` |

### Service Account & RBAC

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account with RBAC | `true` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.name` | Service account name | `""` |

### Optional Features

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podDisruptionBudget.enabled` | Enable PodDisruptionBudget | `false` |
| `podDisruptionBudget.minAvailable` | Minimum available pods | `1` |
| `autoscaling.enabled` | Enable HorizontalPodAutoscaler | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `80` |

## Secret Format

### Application Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: fastgateway-secrets
type: Opaque
stringData:
  jwt-secret: <min-32-characters>
  encryption-key: <32-bytes-base64>
  admin-password: <admin-password>
```

### Database Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: fastgateway-database
type: Opaque
stringData:
  username: <db-username>
  password: <db-password>
  database: <db-name>
```

## RBAC Permissions

The chart creates a ClusterRole with permissions for:

- Gateway API resources (Gateway, HTTPRoute, GRPCRoute, TCPRoute, TLSRoute, GatewayClass, ReferenceGrant)
- Envoy Gateway resources (EnvoyProxy, SecurityPolicy, Backend, BackendTrafficPolicy, HTTPRouteFilter, ClientTrafficPolicy)
- Core resources (Namespaces, Services, Secrets, ConfigMaps, Pods, Deployments)

## Uninstall

```bash
helm uninstall fastgateway -n <namespace>
```
