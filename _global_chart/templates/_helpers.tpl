{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "demo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "demo.fullname" -}}
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


{{/* Allow KubeVersion to be overridden. */}}
{{- define "menorak8s.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride -}}
{{- end -}}
{{/* Get Ingress API Version */}}
{{- define "menorak8s.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" (include "menorak8s.kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
      {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
      {{- print "apiVersion: extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}
{{/* Check Ingress stability */}}
{{- define "menorak8s.ingress.isTanzu" -}}
  {{- eq (include "menorak8s.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{- define "menorak8s.ingress.isStable" -}}
  {{- eq (include "menorak8s.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}
{{/* Check Ingress supports pathType */}}
{{/* pathType was added to networking.k8s.io/v1beta1 in Kubernetes 1.18 */}}
{{- define "menorak8s.ingress.supportsPathType" -}}
  {{- or (eq (include "menorak8s.ingress.isStable" .) "true") (and (eq (include "menorak8s.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" (include "menorak8s.kubeVersion" .))) -}}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "demo.labels" -}}
helm.sh/chart: {{ include "demo.chart" . }}
{{ include "demo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "demo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "demo.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
