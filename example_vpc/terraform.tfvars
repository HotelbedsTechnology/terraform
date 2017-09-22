# File name terraform/modules/aws_vpc/terraform.tfvars

# AWS specific variables
aws_access_key = "<add your access key here>"
aws_secret_key = "<add your secret key here>"

aws_cidr = "192.168.0.0/16"
aws_public_subnets = ["192.168.1.0/24", "192.168.2.0/24"]
aws_private_subnets = ["192.168.10.0/24", "192.168.20.0/24"]
