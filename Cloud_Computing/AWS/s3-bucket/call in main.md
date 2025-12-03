```terraform
module "s3" {

  source       = "../modules/s3"

  project_name = var.project_name

}
```