Terraform you can scale the number of EC2 instances in **two main ways**:

---

#### Option 1: Using `count`

The simplest method.


```
resource "aws_instance" "my_ec2" {   
count         = var.instance_count   
ami           = var.ami   
instance_type = var.instance_type   
subnet_id     = element(module.vpc.public_subnet_ids, count.index)   
key_name      = var.key_name    

tags = {     Name = "my-ec2-${count.index + 1}"   } }`
```
And in your `variables.tf`:
```
variable "instance_count" {   
type    = number   default = 3 
}
```
👉 This will create 3 EC2 instances with names `my-ec2-1`, `my-ec2-2`, `my-ec2-3`.

---
#### Option 2: Using `for_each` with a map

This is more flexible if you want different tags or configs per instance.

```
variable "instances" {   
type = map(string)  
 default = {     
 "jenkins"   = "t3.small"     
 "sonarqube" = "t3.medium"     
 "docker"    = "t3.small"   
 }
}  
 
 resource "aws_instance" "my_ec2" {   
 for_each      = var.instances   
 ami           = var.ami   
 instance_type = each.value   
 subnet_id     = element(module.vpc.public_subnet_ids, 0)   
 key_name      = var.key_name    
 
 tags = {     
 Name = each.key   
	} 
}

```
👉 This creates one instance per entry in the map, with a **different name and instance type**.

---

## ✅ Option 3: Use a module with `count`

Since you’re already using modules (`jenkins_instance`, `sonarqube_instance`, etc.), you can parameterize them too:


```
module "app_servers" {   
source   = "../MODULES/EC2"   
count    = var.instance_count   
ami      = var.ami   
key_name = var.key_name    
project_name_1 = "app-${count.index + 1}"  
 instance_type  = var.instance_type   
 subnet_id      = element(module.vpc.public_subnet_ids, count.index)   security_group_ids = [module.master_sg.master_sg] 
}
```

---

