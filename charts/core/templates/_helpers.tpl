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
  {{- $x_runtime := "" }}
  {{- $x_runtimePath := "" }}

  {{- if .Values.containerRuntime -}}
    {{- $x_runtime = .Values.containerRuntime.name -}}
    {{- $x_runtimePath = .Values.containerRuntime.runTimePath -}}
  {{/* Keep legacy support for old helm configs */}}
  {{- else if .Values.k3s.enabled -}}
    {{- $x_runtime = "k3s" -}}
    {{- $x_runtimePath = .Values.k3s.runtimePath -}}
  {{- else if .Values.bottlerocket.enabled -}}
    {{- $x_runtime = "dockershim" -}}
    {{- $x_runtimePath = .Values.bottlerocket.runtimePath -}}
  {{- else if .Values.containerd.enabled -}}
    {{- $x_runtime = "containerd" -}}
    {{- $x_runtimePath = .Values.containerd.path -}}
  {{- else if .Values.crio.enabled -}}
    {{- $x_runtime = "crio" -}}
    {{- $x_runtimePath = .Values.crio.path -}}
  {{/* Autodetection support */}}
  {{ else -}}
      {{- /* User did not configure the container runtime engine, 
           * Attempting best effort detection of the runtime engine. 
           */ -}}
      {{- if contains "gke" .Capabilities.KubeVersion.Version  -}}
        {{- $x_runtime = "containerd" -}}
      {{- else if contains "bottlerocket" .Capabilities.KubeVersion.Version  -}}
        {{- $x_runtime = "dockershim" -}}
      {{- else if contains "crio" .Capabilities.KubeVersion.Version  -}}
        {{- $x_runtime = "crio" -}}
      {{- else if contains "k3s" .Capabilities.KubeVersion.Version  -}}
        {{- $x_runtime = "k3s" -}}
      {{- else if contains "rke2" .Capabilities.KubeVersion.Version  -}}
        {{- $x_runtime = "k3s" -}}
      {{- else if contains "eks" .Capabilities.KubeVersion.Version  -}}
        {{- $x_runtime = "containerd" -}}
      {{- else -}}
        {{- $x_runtime = "unknown" -}}
      {{- end -}}
  {{- end -}}



  {{- if $x_runtimePath -}}
    {{- print $x_runtimePath -}}
  {{- else if eq $x_runtime "k3s" -}}
    {{- print "/run/k3s/containerd/containerd.sock" -}}
  {{- else if eq $x_runtime "crio" -}}
    {{- print "/var/run/crio/crio.sock" -}}
  {{- else if eq $x_runtime "containerd" -}}
    {{- print "/var/run/containerd/containerd.sock" -}}
  {{- else if eq $x_runtime "docker" -}}
    {{- print "/var/run/docker.sock" -}}
  {{- else if eq $x_runtime "dockershim" -}} 
    {{- print "/run/dockershim.sock" -}}
  {{- else -}}
    {{- /* Assume docker fallback */ -}}
    {{- print "/var/run/docker.sock" -}}
  {{end}}
{{end}}