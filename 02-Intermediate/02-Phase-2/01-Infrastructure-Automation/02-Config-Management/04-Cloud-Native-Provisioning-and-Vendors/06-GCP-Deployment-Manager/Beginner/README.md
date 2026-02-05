# 🔰 GCP Deployment Manager Beginner Level

## 📋 Learning Objectives
- ✅ Write a basic YAML configuration file
- ✅ Understand the `resources` list
- ✅ Deploy and delete configurations using `gcloud`

---

## 📝 Configuration Structure

A basic configuration is a YAML file that lists the resources you want to create.

```yaml
resources:
- name: my-vm
  type: compute.v1.instance
  properties:
    zone: us-central1-a
    machineType: zones/us-central1-a/machineTypes/n1-standard-1
    disks:
    - deviceName: boot
      type: PERSISTENT
      boot: true
      autoDelete: true
      initializeParams:
        sourceImage: projects/debian-cloud/global/images/family/debian-11
    networkInterfaces:
    - network: global/networks/default
      accessConfigs:
      - name: External NAT
        type: ONE_TO_ONE_NAT
```

---

## 🚀 Deployment Commands

### Create a Deployment
```bash
gcloud deployment-manager deployments create my-first-deployment \
    --config my-config.yaml
```

### Update a Deployment
```bash
gcloud deployment-manager deployments update my-first-deployment \
    --config updated-config.yaml
```

### Delete a Deployment
```bash
gcloud deployment-manager deployments delete my-first-deployment
```

### View Resources
```bash
gcloud deployment-manager resources list --deployment my-first-deployment
```

---

## 🔑 Key Concepts
- **Configuration**: The YAML file describing the set of resources.
- **Resource**: An individual GCP service instance.
- **Type**: The specific service and version (e.g., `compute.v1.instance`).
- **Properties**: The settings for the resource.
