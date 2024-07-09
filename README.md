# 2 tier Application on AWS using Terraform


## Architecture Diagram
![2-tier-application drawio (1)](https://github.com/Sh1vam6/2tier_application_on_AWS_using_Terraform/assets/97598721/dd01ed2d-3d0c-40cd-bde4-6d65cf05257d)

## 🖥️ Installation of Terraform

**Note**: Install terraform from its documentation. [https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli]

👉 let install dependency to deploy the application 

```sh
cd main
terraform init 
```


edit below file accoding to your configuration
```sh
vim main/backend.tf
```
add below code in main/backend.tf
```sh
terraform {
  backend "s3" {
    bucket = "BUCKET_NAME"
    key    = "backend/FILE_NAME_TO_STORE_STATE.tfstate"
    region = "us-east-1"
  }
}
```
### 🏠Lets setup the variable for our Infrastructure
create one file with the name of `terraform.tfvars` 
```sh
vim main/terraform.tfvars
```

add below contents into `main/terraform.tfvars` file
```javascript
region           = ""
project_name     = ""
vpc_cidr         = ""
my_ip            = ""
domain_name      = ""
alternative_name = ""
instance_type    = ""
desired_capacity = ""
min_size         = ""
max_size         = ""
ami              = ""




```

## ✈️ Now we are ready to deploy our application on cloud ⛅
get into project directory 
```sh
cd main
```

type below command to see plan of the exection 
```sh
terraform plan
```

Then , finally type below comand 
```sh
terraform apply 
```

type `yes`, it will prompt you for permission..





