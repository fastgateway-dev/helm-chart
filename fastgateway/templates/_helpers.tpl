{{/*
Expand the name of the chart.
*/}}
{{- define "fastgateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fastgateway.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fastgateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fastgateway.labels" -}}
helm.sh/chart: {{ include "fastgateway.chart" . }}
{{ include "fastgateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fastgateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fastgateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend labels
*/}}
{{- define "fastgateway.backend.labels" -}}
{{ include "fastgateway.labels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "fastgateway.backend.selectorLabels" -}}
{{ include "fastgateway.selectorLabels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "fastgateway.frontend.labels" -}}
{{ include "fastgateway.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "fastgateway.frontend.selectorLabels" -}}
{{ include "fastgateway.selectorLabels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fastgateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fastgateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "fastgateway.secretName" -}}
{{- required "secrets.existingSecret is required" .Values.secrets.existingSecret }}
{{- end }}

{{/*
Create the database secret name
*/}}
{{- define "fastgateway.databaseSecretName" -}}
{{- required "database.existingSecret is required" .Values.database.existingSecret }}
{{- end }}

{{/*
Create the database URL
*/}}
{{- define "fastgateway.databaseURL" -}}
{{- printf "postgres://$(DATABASE_USER):$(DATABASE_PASSWORD)@%s:%v/$(DATABASE_NAME)?sslmode=disable" (required "database.host is required" .Values.database.host) (int .Values.database.port) }}
{{- end }}

{{/*
Backend service URL for frontend
*/}}
{{- define "fastgateway.backendURL" -}}
{{- printf "http://%s-backend:%v" (include "fastgateway.fullname" .) (int .Values.backend.service.port) }}
{{- end }}

{{/*
Image pull secrets
*/}}
{{- define "fastgateway.imagePullSecrets" -}}
{{- with .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
