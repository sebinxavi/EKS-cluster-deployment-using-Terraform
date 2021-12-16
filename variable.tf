## Declare the Project Details
#-------------------------------------
variable "region" {}
variable "project" {}

## Declare the VPC Details
#-------------------------------------
variable "vpc_cidr" {}
variable "public1_cidr" {}
variable "public2_cidr" {}
variable "public3_cidr" {}
variable "private1_cidr" {}
variable "private2_cidr" {}
variable "private3_cidr" {}
variable "public1_az" {}
variable "public2_az" {}
variable "public3_az" {}
variable "private1_az" {}
variable "private2_az" {}
variable "private3_az" {}

## Declare the EC2 Instance Details
#-------------------------------------
variable "instance_type" {}
variable "ami" {}
