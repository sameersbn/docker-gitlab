{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gitlab.name" -}}
{{- default "gitlab" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gitlab.fullname" -}}
{{- $name := default "gitlab" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "gitlab.labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app: "{{ include "gitlab.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "gitlab.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ include "gitlab.name" . }}"
{{- end -}}

{{- define "gitlab.autoGenCert" -}}
  {{- if and .Values.expose.tls.enabled (not .Values.expose.tls.secretName) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.redis" -}}
  {{- printf "%s-redis" (include "gitlab.fullname" .) -}}
{{- end -}}

{{- define "gitlab.database" -}}
  {{- printf "%s-database" (include "gitlab.fullname" .) -}}
{{- end -}}

{{- define "gitlab.core" -}}
  {{- printf "%s-core" (include "gitlab.fullname" .) -}}
{{- end -}}

{{- define "gitlab.core.serviceName" -}}
  {{- if or (eq .Values.expose.type "clusterIP") (eq .Values.expose.type "ingress") -}}
    {{- default (include "gitlab.core" .) .Values.expose.clusterIP.name -}}
  {{- else if eq .Values.expose.type "nodePort" -}}
    {{- default (include "gitlab.core" .) .Values.expose.nodePort.name -}}
  {{- else if eq .Values.expose.type "loadBalancer" -}}
    {{- default (include "gitlab.core" .) .Values.expose.loadBalancer.name -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.core.backupSchedule" -}}
  {{- if ne .Values.core.env.GITLAB_BACKUP_SCHEDULE "disable" -}}
    {{- $split := splitList ":" .Values.core.env.GITLAB_BACKUP_TIME }}
    {{- if eq .Values.core.env.GITLAB_BACKUP_SCHEDULE "daily" -}}
      {{- printf "%s %s * * *" (index $split 1 ) (index $split 0 ) -}}
    {{- else if eq .Values.core.env.GITLAB_BACKUP_SCHEDULE "weekly" -}}
      {{- printf "%s %s * * 0" (index $split 1 ) (index $split 0 ) -}}
    {{- else if eq .Values.core.env.GITLAB_BACKUP_SCHEDULE "monthly" -}}
      {{- printf "%s %s 01 * *" (index $split 1 ) (index $split 0 ) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.ingress" -}}
  {{- printf "%s-ingress" (include "gitlab.fullname" .) -}}
{{- end -}}

{{- define "gitlab.database.host" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- include "gitlab.database" . }}
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.database.port" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "5432" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.database.rawUsername" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "gitlab" -}}
  {{- else -}}
    {{- .Values.database.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.database.encryptedUsername" -}}
  {{- include "gitlab.database.rawUsername" . | b64enc | quote -}}
{{- end -}}

{{- define "gitlab.database.rawPassword" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.database.encryptedPassword" -}}
  {{- include "gitlab.database.rawPassword" . | b64enc | quote -}}
{{- end -}}

{{- define "gitlab.database.rawDatabaseName" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "gitlabhq_production" -}}
  {{- else -}}
    {{- .Values.database.external.databaseName -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.database.encryptedDatabaseName" -}}
  {{- include "gitlab.database.rawDatabaseName" . | b64enc | quote -}}
{{- end -}}

{{- define "gitlab.redis.host" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- include "gitlab.redis" . -}}
  {{- else -}}
    {{- .Values.redis.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.redis.port" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- printf "%s" "6379" -}}
  {{- else -}}
    {{- .Values.redis.external.port -}}
  {{- end -}}
{{- end -}}
