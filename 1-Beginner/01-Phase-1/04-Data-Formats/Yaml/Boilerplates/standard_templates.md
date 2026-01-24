# 🏗️ YAML Boilerplates: Production-Grade Templates

This directory contains industry-standard YAML templates used in modern cloud automation.

## 1. Kubernetes Deployment Template
Standard deployment manifest with resource limits and health probes.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "250m"
            memory: "256Mi"
        livenessProbe:
          httpGet:
            path: /healthz
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
```

## 2. Ansible Playbook Template
A structured playbook for web server configuration.

```yaml
---
- name: Configure Web Servers
  hosts: webservers
  become: yes
  vars:
    http_port: 80
    max_clients: 200
  tasks:
    - name: Ensure Apache is installed
      ansible.builtin.yum:
        name: httpd
        state: present

    - name: Copy index.html
      ansible.builtin.template:
        src: index.html.j2
        dest: /var/www/html/index.html
        mode: '0644'

    - name: Restart Apache service
      ansible.builtin.service:
        name: httpd
        state: restarted
```
