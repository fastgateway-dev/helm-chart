<div align="center">
  <img src="https://raw.githubusercontent.com/fastgateway-dev/helm-chart/main/fastgateway/logo.png" alt="FastGateway" width="110">

  <h1>FastGateway</h1>

  <p><strong>Manage the Kubernetes Gateway API without hand-writing YAML.</strong></p>

  <p>
    <a href="https://github.com/fastgateway-dev/helm-chart"><img alt="Chart Version" src="https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffastgateway-dev%2Fhelm-chart%2Fmain%2Ffastgateway%2FChart.yaml&query=%24.version&label=chart&color=blue"></a>
    <a href="https://github.com/fastgateway-dev/helm-chart"><img alt="App Version" src="https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffastgateway-dev%2Fhelm-chart%2Fmain%2Ffastgateway%2FChart.yaml&query=%24.appVersion&label=app&color=informational"></a>
    <a href="https://github.com/fastgateway-dev/backend-v2/pkgs/container/backend-v2"><img alt="Backend Image" src="https://img.shields.io/badge/ghcr.io-backend--v2-informational"></a>
    <a href="https://github.com/fastgateway-dev/frontend-v2/pkgs/container/frontend-v2"><img alt="Frontend Image" src="https://img.shields.io/badge/ghcr.io-frontend--v2-informational"></a>
  </p>

  <p>
    <a href="https://fastgateway.dev">Website</a> ·
    <a href="https://github.com/fastgateway-dev/backend-v2">Backend</a> ·
    <a href="https://github.com/fastgateway-dev/frontend-v2">Frontend</a>
  </p>
</div>

---

A Helm chart for FastGateway - Kubernetes Gateway API Management Platform

This Helm chart deploys the **FastGateway** platform — a Go backend ([`backend-v2`](https://github.com/fastgateway-dev/backend-v2)) and a Next.js frontend ([`frontend-v2`](https://github.com/fastgateway-dev/frontend-v2)), backed by PostgreSQL — onto Kubernetes.

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
- Envoy Gateway resources (EnvoyProxy, SecurityPolicy, Backend, BackendTrafficPolicy, HTTPRouteFilter, ClientTrafficPolicy, EnvoyExtensionPolicy)
- cert-manager resources (Issuer, Certificate, CertificateRequest) for certificate management
- Core resources (Namespaces, Services, Secrets, ConfigMaps, Pods, Deployments)
- CustomResourceDefinitions (read-only, to detect the installed Gateway API version)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backend.affinity | object | `{}` |  |
| backend.autoscaling.enabled | bool | `false` |  |
| backend.autoscaling.maxReplicas | int | `10` |  |
| backend.autoscaling.minReplicas | int | `1` |  |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| backend.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| backend.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| backend.containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| backend.image.pullPolicy | string | `"IfNotPresent"` |  |
| backend.image.repository | string | `"ghcr.io/fastgateway-dev/backend-v2"` |  |
| backend.image.tag | string | `"v0.2.0"` |  |
| backend.nodeSelector | object | `{}` |  |
| backend.podAnnotations | object | `{}` |  |
| backend.podDisruptionBudget.enabled | bool | `false` |  |
| backend.podDisruptionBudget.minAvailable | int | `1` |  |
| backend.replicaCount | int | `1` |  |
| backend.resources.limits.cpu | string | `"500m"` |  |
| backend.resources.limits.memory | string | `"512Mi"` |  |
| backend.resources.requests.cpu | string | `"100m"` |  |
| backend.resources.requests.memory | string | `"128Mi"` |  |
| backend.securityContext.runAsNonRoot | bool | `true` |  |
| backend.securityContext.runAsUser | int | `1000` |  |
| backend.service.port | int | `8081` |  |
| backend.service.type | string | `"ClusterIP"` |  |
| backend.tolerations | list | `[]` |  |
| config.adminEmail | string | `"admin@fastgateway.local"` |  |
| config.adminUsername | string | `"admin"` |  |
| config.logLevel | string | `"info"` |  |
| database.external.existingSecret | string | `""` |  |
| database.external.host | string | `""` |  |
| database.external.port | int | `5432` |  |
| database.external.sslcert | string | `""` |  |
| database.external.sslkey | string | `""` |  |
| database.external.sslmode | string | `""` |  |
| database.external.sslrootcert | string | `""` |  |
| database.internal.database | string | `"fastgateway"` |  |
| database.internal.image.pullPolicy | string | `"IfNotPresent"` |  |
| database.internal.image.repository | string | `"postgres"` |  |
| database.internal.image.tag | string | `"16-alpine"` |  |
| database.internal.password | string | `"fastgateway"` |  |
| database.internal.resources.limits.cpu | string | `"500m"` |  |
| database.internal.resources.limits.memory | string | `"512Mi"` |  |
| database.internal.resources.requests.cpu | string | `"100m"` |  |
| database.internal.resources.requests.memory | string | `"128Mi"` |  |
| database.internal.storage.size | string | `"1Gi"` |  |
| database.internal.storage.storageClassName | string | `""` |  |
| database.internal.username | string | `"fastgateway"` |  |
| database.type | string | `"internal"` |  |
| frontend.affinity | object | `{}` |  |
| frontend.autoscaling.enabled | bool | `false` |  |
| frontend.autoscaling.maxReplicas | int | `5` |  |
| frontend.autoscaling.minReplicas | int | `1` |  |
| frontend.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| frontend.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| frontend.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| frontend.containerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| frontend.image.pullPolicy | string | `"IfNotPresent"` |  |
| frontend.image.repository | string | `"ghcr.io/fastgateway-dev/frontend-v2"` |  |
| frontend.image.tag | string | `"v0.2.0"` |  |
| frontend.nodeSelector | object | `{}` |  |
| frontend.podAnnotations | object | `{}` |  |
| frontend.podDisruptionBudget.enabled | bool | `false` |  |
| frontend.podDisruptionBudget.minAvailable | int | `1` |  |
| frontend.replicaCount | int | `1` |  |
| frontend.resources.limits.cpu | string | `"200m"` |  |
| frontend.resources.limits.memory | string | `"256Mi"` |  |
| frontend.resources.requests.cpu | string | `"50m"` |  |
| frontend.resources.requests.memory | string | `"64Mi"` |  |
| frontend.securityContext.runAsNonRoot | bool | `true` |  |
| frontend.securityContext.runAsUser | int | `1001` |  |
| frontend.service.port | int | `3001` |  |
| frontend.service.type | string | `"ClusterIP"` |  |
| frontend.tolerations | list | `[]` |  |
| global.imagePullSecrets | list | `[]` |  |
| secrets.existingSecret | string | `""` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| waf.image | string | `"ghcr.io/corazawaf/coraza-proxy-wasm"` |  |
| waf.sha256 | string | `""` |  |
| waf.tag | string | `"0.6.0"` |  |

## Uninstall

```bash
helm uninstall fastgateway -n <namespace>
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| zufardhiyaulhaq |  |  |
