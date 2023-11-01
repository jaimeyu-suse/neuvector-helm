{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "neuvector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "neuvector.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "neuvector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Lookup secret.
*/}}
{{- define "neuvector.secrets.lookup" -}}
{{- $value := "" -}}
{{- $secretData := (lookup "v1" "Secret" .namespace .secret).data  -}}
{{- if and $secretData (hasKey $secretData .key) -}}
  {{- $value = index $secretData .key -}}
{{- else if .defaultValue -}}
  {{- $value = .defaultValue | toString | b64enc -}}
{{- end -}}
{{- if $value -}}
{{- printf "%s" $value -}}
{{- end -}}
{{- end -}}

{{/* Templating the container runtime socket paths for neuvector */}}
{{- define "helper.runtime" -}}
  {{- if empty .Values.containerRuntime }}
    {{- print "/var/run/docker.sock" -}}
  {{- else if .Values.containerRuntime.customRunTimePath }} 
    {{- print .Values.containerRuntime.runTimePath -}}
  {{- else if contains .Values.containerRuntime.name "k3s" }}
    {{- print "/run/k3s/containerd/containerd.sock" -}}
  {{- else if contains .Values.containerRuntime.name "crio" }}
    {{- print "/var/run/crio/crio.sock" -}}
  {{- else if contains .Values.containerRuntime.name "containerd" }}
    {{- print "/var/run/containerd/containerd.sock" -}}
  {{- else if contains .Values.containerRuntime.name "bottlerocket" }}
    {{- print "/run/dockershim.sock" -}}
  {{- else }} 
    {{- print "/var/run/docker.sock" -}}
  {{end}}
{{end}}