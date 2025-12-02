{{- define "jira.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "jira.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "jira.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the shared home PVC name based on backend selection.
*/}}
{{- define "jira.sharedHome.pvcName" -}}
{{- if eq (default "efs" .Values.jira.sharedHome.backend) "azurefile" -}}
{{ include "jira.fullname" . }}-azurefile-pvc
{{- else -}}
{{ include "jira.fullname" . }}-efs-pvc
{{- end -}}
{{- end -}}
