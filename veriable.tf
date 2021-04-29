# Accesskey 
variable "access_key" {}
variable "secret_key" {}
description = " user aws secret key"

# AWS Region
variable "region" {
  type = "string"
  default =  "ap-south-1"
}

#AZ
 
variable "azs" {
  type = "list"
  default = ["ap-south-1a", "ap-south-1b"]
  description = "Availablity zones"

}

variable "keyname" {
  default = "mwiki"
  description = "the ssh key to use in the EC2 machines"

}

# RHEL AMI
variable "aws_ami" {
  default="ami-0d70a070"
}

# VPC and Subnet
variable "aws_cidr_vpc" {
  default = "10.4.0.0/16"
  description = "the vpc cdir"

}

variable "aws_cidr_subnet1" {
  default = "10.4.1.0/24"
  description = "the cidr of the subnet"
}

variable "aws_cidr_subnet2" {
  default = "10.4.2.0/24"
  description = "the cidr of the subnet"

}

variable "aws_sg" {
  default = "sg_mwiki"
}

variable "aws_tags" {
  type = "map"
  default = {
    "webserver" = "webserver"
    "dbserver" = "dbserver" 
  }
}

variable "aws_instance_type" {
  default = "t2.micro"
}
