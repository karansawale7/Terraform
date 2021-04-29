# Terraform

 
#Pre-Requisites: 
---------------------------
1. Terraform is installed . 
```
[root@ip-172-31-40-121 terraform]# terraform -v
Terraform v0.14.10
```

2. AWS Secret variables are set for user. 

```
export AWS_ACCESS_KEY_ID='AKIAYAXCSEXXXXXXXXXXXXX'
export AWS_SECRET_ACCESS_KEY='aUIIMPpx1wkz9EyYOe+bXXXXXXXXXXXXXX'

```


Steps to run code. 
---------------


```

git clone https://github.com/karansawale7/Terraform.git

terraform init -input=false

terraform plan -out=tfplan -input=false

terraform apply -input=false tfplan 

terraform output pem > mwiki.pem

```


