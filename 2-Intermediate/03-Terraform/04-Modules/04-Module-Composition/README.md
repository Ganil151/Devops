# Module Composition

Composition is the act of combining small, specialized modules to build a complex system.

## Composition Strategies

### 1. Data-Driven Composition (Recommended)
One module's output becomes another module's input.
```hcl
module "vpc" {
  source = "./modules/vpc"
}

module "db" {
  source    = "./modules/rds"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnets[0]
}
```

### 2. Wrapper Modules (Aggregators)
Create a "Giant" module that calls several "Small" modules inside it to enforce a company-standard architecture.

## Managing Dependencies
Terraform usually detects dependencies automatically via your variable/output links. However, if a module doesn't have a direct data link but must wait for another, use `depends_on`.

```hcl
module "iam_roles" {
  source = "./iam"
}

module "eks" {
  source = "./eks"
  depends_on = [module.iam_roles] # Wait for IAM to be ready
}
```

---

## 🏗️ Real-Life Scenario: The "Lego" Architecture
**Problem**: An Enterprise wants a "One-Click Environment."
**Solution**: They build a `blueprint` module. Inside it, they call `module.network`, `module.security`, `module.k8s`, and `module.logging`. 
- The **Network** module passes its `vpc_id` to **Security**. 
- **Security** passes its `sg_id` to **k8s**. 
- **k8s** passes its `cluster_id` to **Logging**.
This chain creates a perfectly orchestrated environment that can be spun up in 10 minutes.

---

## ❓ Interview Questions
1.  **How do modules communicate with each other?**
    *   *Answer*: Through Outputs and Inputs. Module A exports an `output`, which the Root Module then passes into Module B as a variable `input`.
2.  **What are the downsides of deep module nesting (e.g., Module A calls B, which calls C, which calls D)?**
    *   *Answer*: It becomes very difficult to debug, creates "Propagating Variables" (passing the same variable through 4 layers), and makes the system brittle. Aim for "Flat" composition.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Can one module read the `locals` of another module?** (No)
2.  **Which meta-argument forces a module to wait for another?** (`depends_on`)
3.  **True/False: Module composition reduces the "Blast Radius."** (True - By isolating components into separate modules)
4.  **How do you access a module's output?** (`module.module_name.output_name`)
5.  **What is a "Golden Image" module?** (A module that provides a pre-approved, standard configuration for a complex resource)
