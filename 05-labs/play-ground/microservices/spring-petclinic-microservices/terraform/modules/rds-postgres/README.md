# RDS Module

Provisions a MySQL RDS instance.

## Usage

```hcl
module "rds" {
  source = "../../modules/rds"
  environment = "dev"
  identifier = "petclinic-db"
  username   = "admin"
  password   = var.db_password
}
```
