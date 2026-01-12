# ❓ GCP Deployment Manager Interview & Quiz Questions

## 📋 Interview Questions

**Q1: What are the three languages supported by Deployment Manager templates?**
**A:** YAML (for the main configuration), and Jinja2 or Python (for the templates).

**Q2: What is a 'Manifest' in Deployment Manager?**
**A:** A manifest is a read-only record of the actual configuration that was used to create or update a deployment. It includes the original configuration and the expanded list of resources.

**Q3: How do you handle dependencies between resources in a YAML config?**
**A:** Unlike CloudFormation or Terraform, Deployment Manager implicitly handles most dependencies based on resource references. However, you can explicitly define them using the `metadata.dependsOn` property.

**Q4: Explain the purpose of a Schema file.**
**A:** A schema file (.schema) defines the interface for a template. It specifies what properties the template accepts, their types, required fields, and default values.

**Q5: What is the 'Runtime Configurator'?**
**A:** It's a separate service used to coordinate resource creation and software configuration. It allows DM to wait for a signal from a script running inside a VM before marking a resource as complete.

---

## 📝 Quiz Section (20+ Questions)

1. **Which command is used to start a new deployment?**
   - A) gcloud dm deploy
   - B) gcloud deployment-manager deployments create ✅
   - C) gcloud resources create
   - D) gcloud compute deployments up

2. **Which file acts as the entry point for a deployment?**
   - A) main.jinja
   - B) config.yaml ✅
   - C) deploy.py
   - D) schema.yaml

3. **In a template, how do you access a property passed from the config?**
   - A) {{ properties["name"] }} ✅
   - B) {{ params["name"] }}
   - C) {{ env["name"] }}
   - D) $name

4. **What is the file extension for a Jinja2 template in DM?**
   - A) .yaml
   - B) .j2
   - C) .jinja ✅
   - D) .tpl

5. **Which built-in variable provides the current project ID?**
   - A) env["project_id"]
   - B) env["project"] ✅
   - C) project.id
   - D) $PROJECT

6. **What does 'gcloud deployment-manager deployments stop' do?**
   - A) Deletes all resources
   - B) Cancels an ongoing deployment or update ✅
   - C) Suspends the VMs
   - D) Freezes the UI

7. **Which section of the YAML file is used to include other files?**
   - A) includes
   - B) references
   - C) imports ✅
   - D) modules

8. **Python templates must define which function?**
   - A) main()
   - B) run()
   - C) GenerateConfig() ✅
   - D) start()

9. **Which attribute is used to explicitly set dependency order?**
   - A) dependsOn ✅
   - B) after
   - C) requires
   - D) sequence

10. **What is a 'Composite Type'?**
    - A) A resource type that combines multiple GCP services
    - B) A template registered as a custom type in the project ✅
    - C) A data type in Python
    - D) A type of database

11. **Can Deployment Manager manage resources in a different project?**
    - A) No
    - B) Yes, if the service account has permissions ✅
    - C) Only in the same organization
    - D) Only if they share a network

12. **Which command shows the history of deployments?**
    - A) gcloud dm history
    - B) gcloud deployment-manager deployments list ✅
    - C) gcloud log read
    - D) gcloud history dm

13. **Is it possible to preview a deployment without creating resources?**
    - A) No
    - B) Yes, using the `--preview` flag ✅
    - C) Only for YAML-only configs
    - D) Only via the Console

14. **What happens during the 'Expansion' phase?**
    - A) The cloud infrastructure grows
    - B) Templates (Jinja/Python) are processed into a flat list of resources ✅
    - C) The cost increases
    - D) More nodes are added to the cluster

15. **Which service is used for Wait Conditions?**
    - A) Cloud Monitoring
    - B) Runtime Configurator ✅
    - C) Cloud Pub/Sub
    - D) Cloud Functions

16. **How do you define a default value for a property?**
    - A) In the YAML file
    - B) In the Schema file ✅
    - C) In the Python code
    - D) In the CLI command

17. **What is the default behavior if a resource fails to create?**
    - A) DM stops and leaves resources as-is ✅ (Unless rollback is enabled)
    - B) Everything is deleted
    - C) It retries forever
    - D) It skips that resource

18. **Which keyword starts the list of actual services in the YAML?**
    - A) components
    - B) infrastructure
    - C) resources ✅
    - D) services

19. **What is the 'gcloud deployment-manager manifests' command for?**
    - A) Creating documentation
    - B) Viewing the detailed record of a deployment's resources and state ✅
    - C) Listing all available resource types
    - D) Deleting logs

20. **Can you use Python libraries in DM Python templates?**
    - A) No
    - B) Yes, but only standard libraries and within limits ✅
    - C) Only if they are pre-installed by Google
    - D) Only `requests` and `json`

21. **What is the 'type' field in a resource definition?**
    - A) The name of the resource
    - B) The identifier for the GCP API resource being created ✅
    - C) The data type
    - D) The billing category
