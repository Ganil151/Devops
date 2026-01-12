# Chart Templating

One of the most powerful features of Helm is its ability to use Go templates to dynamically generate Kubernetes manifests.

---

## 🏗️ Core Concepts

### 1. Variables and Values
Access values defined in `values.yaml` using the `.Values` object.
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.configName }}
```

### 2. Template Functions
Helm provides over 60 functions for manipulating data.
- `upper`: Converts string to uppercase.
- `quote`: Wraps string in double quotes.
- `default`: Provides a fallback value.
```yaml
name: {{ .Values.appName | upper | quote }}
status: {{ .Values.status | default "active" }}
```

### 3. Logic and Loops
Use `if/else` and `range` to handle complex logic.
```yaml
# Conditional
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
...
{{- end }}

# Looping over a list
env:
{{- range .Values.envVars }}
- name: {{ .name }}
  value: {{ .value | quote }}
{{- end }}
```

### 4. Named Templates (Partials)
Reuse code snippets across different files using `define` and `template`/`include`.
```yaml
# Defined in _helpers.tpl
{{- define "myapp.labels" -}}
app: myapp
release: {{ .Release.Name }}
{{- end -}}

# Used in deployment.yaml
metadata:
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
```

---

## 💡 Best Practices
- **nindent**: Use `nindent` instead of `indent` for better newline handling.
- **Hyphens**: Use `{{-` to remove whitespace around your logic blocks.
- **Dry-run**: Always verify your templates with `helm install --dry-run --debug`.
- **Validation**: Use `tpl` function only when necessary as it can be hard to troubleshoot.
