 #variable "region" {}
 variable "main_vpc_cidr" {}
 variable "public_subnets" {
     description = "A list of public subnets inside the VPC"
     type        = list(string)
     default     = []
 }
 variable "private_subnets" {
     description = "A list of private subnets inside the VPC"
     type        = list(string)
     default     = []
 }
