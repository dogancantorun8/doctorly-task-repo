{{/*
Expand the name of the chart.
*/}}
{{- define "wordpress.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wordpress.fullname" -}}
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
{{- define "wordpress.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wordpress.labels" -}}
helm.sh/chart: {{ include "wordpress.chart" . }}
{{ include "wordpress.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels for WordPress
*/}}
{{- define "wordpress.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wordpress.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: wordpress
{{- end }}

{{/*
Selector labels for MySQL
*/}}
{{- define "wordpress.mysql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wordpress.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: mysql
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wordpress.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wordpress.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the WordPress secret
*/}}
{{- define "wordpress.secretName" -}}
{{- printf "%s-secrets" (include "wordpress.fullname" .) }}
{{- end }}

{{/*
Create the name of the MySQL secret
*/}}
{{- define "wordpress.mysql.secretName" -}}
{{- printf "%s-mysql-secrets" (include "wordpress.fullname" .) }}
{{- end }}

{{/*
Create the name of the WordPress ConfigMap
*/}}
{{- define "wordpress.configMapName" -}}
{{- printf "%s-config" (include "wordpress.fullname" .) }}
{{- end }}

{{/*
Create the name of the MySQL ConfigMap
*/}}
{{- define "wordpress.mysql.configMapName" -}}
{{- printf "%s-mysql-config" (include "wordpress.fullname" .) }}
{{- end }}

{{/*
Create MySQL connection string
*/}}
{{- define "wordpress.mysql.connectionString" -}}
{{- printf "%s-mysql:%d" (include "wordpress.fullname" .) (.Values.service.mysql.port | int) }}
{{- end }}

{{/*
Generate WordPress admin password
*/}}
{{- define "wordpress.adminPassword" -}}
{{- if .Values.wordpress.adminPassword }}
{{- .Values.wordpress.adminPassword }}
{{- else }}
{{- randAlphaNum 16 }}
{{- end }}
{{- end }}

{{/*
Generate MySQL root password
*/}}
{{- define "wordpress.mysql.rootPassword" -}}
{{- if .Values.mysql.auth.rootPassword }}
{{- .Values.mysql.auth.rootPassword }}
{{- else }}
{{- randAlphaNum 16 }}
{{- end }}
{{- end }}

{{/*
Generate MySQL user password
*/}}
{{- define "wordpress.mysql.userPassword" -}}
{{- if .Values.mysql.auth.password }}
{{- .Values.mysql.auth.password }}
{{- else }}
{{- randAlphaNum 16 }}
{{- end }}
{{- end }}

{{/*
Generate WordPress authentication unique keys and salts
*/}}
{{- define "wordpress.authKey" -}}
{{- randAlphaNum 64 }}
{{- end }}

{{- define "wordpress.secureAuthKey" -}}
{{- randAlphaNum 64 }}
{{- end }}

{{- define "wordpress.loggedInKey" -}}
{{- randAlphaNum 64 }}
{{- end }}

{{- define "wordpress.nonceKey" -}}
{{- randAlphaNum 64 }}
{{- end }}

{{- define "wordpress.authSalt" -}}
{{- randAlphaNum 64 }}
{{- end }}

{{- define "wordpress.secureAuthSalt" -}}
{{- randAlphaNum 64 }}
{{- end }}

{{- define "wordpress.loggedInSalt" -}}
{{- randAlphaNum 64 }}
{{- end }}

{{- define "wordpress.nonceSalt" -}}
{{- randAlphaNum 64 }}
{{- end }}

{{/*
Create WordPress PVC name
*/}}
{{- define "wordpress.pvcName" -}}
{{- printf "%s-wordpress-pvc" (include "wordpress.fullname" .) }}
{{- end }}

{{/*
Create MySQL PVC name
*/}}
{{- define "wordpress.mysql.pvcName" -}}
{{- printf "%s-mysql-pvc" (include "wordpress.fullname" .) }}
{{- end }}

{{/*
Get the WordPress service name
*/}}
{{- define "wordpress.serviceName" -}}
{{- printf "%s-wordpress" (include "wordpress.fullname" .) }}
{{- end }}

{{/*
Get the MySQL service name
*/}}
{{- define "wordpress.mysql.serviceName" -}}
{{- printf "%s-mysql" (include "wordpress.fullname" .) }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "wordpress.annotations" -}}
{{- with .Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Validate required values
*/}}
{{- define "wordpress.validateValues" -}}
{{- if and .Values.mysql.persistence.enabled (not .Values.mysql.persistence.size) }}
{{- fail "MySQL persistence is enabled but no size specified" }}
{{- end }}
{{- if and .Values.wordpress.persistence.enabled (not .Values.wordpress.persistence.size) }}
{{- fail "WordPress persistence is enabled but no size specified" }}
{{- end }}
{{- end }}