terraform {
  backend "s3" {
    bucket = "tarbuckcsv"
    key    = "terraform_office/key"
    region = "ap-south-1"
  }
}

#Creating the VPC
 resource "aws_vpc" "Main" {                
   cidr_block       = var.main_vpc_cidr     # Defining the Main CIDR block
   instance_tenancy = "default"
   tags = {
    Name = "Terraform"
  }
 }
 #Creating Internet Gateway and attaching
 resource "aws_internet_gateway" "IGW" {    
    vpc_id =  aws_vpc.Main.id               # vpc_id will be generated after we create VPC
    tags = {
    Name = "Terraform"
  }
 }
 #Create a Public Subnets
 resource "aws_subnet" "publicsubnets" {   
   vpc_id =  aws_vpc.Main.id
   cidr_block  = "${var.public_subnets}"     # Define CIDR block for public subnets
   tags = {
    Name = "Terraform"
  }
 }

 #Create a Private Subnets             
 resource "aws_subnet" "privatesubnets" {
   vpc_id =  aws_vpc.Main.id
   cidr_block  = "${var.private_subnets}"     # Define CIDR block for private subnets
   tags = {
    Name = "Terraform"
  }
 }
 resource "aws_eip" "nateIP" {
   vpc   = true
   tags = {
    Name = "Terraform"
  }
 }
 #Creating the NAT Gateway using subnet_id and allocation_id
 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.privatesubnets.id
   tags = {
    Name = "TerraformNAT"
  }
 }

 #Route table for Public Subnet
 resource "aws_route_table" "PublicRT" {   
    vpc_id =  aws_vpc.Main.id
         route {
    cidr_block = "0.0.0.0/0"               # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
     }
     tags = {
    Name = "TerraformRTPub"
  }
 }
 #Route table for Private Subnet's
 resource "aws_route_table" "PrivateRT" {  
   vpc_id = aws_vpc.Main.id
   route {
    cidr_block = "0.0.0.0/0"        # Traffic from Private Subnet reaches Internet via NAT Gateway
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    Name = "TerraformRTPri"
  }
 }
 
  resource "aws_route_table_association" "PublicRTassociation" {
  subnet_id = aws_subnet.publicsubnets.id
  route_table_id = aws_route_table.PublicRT.id
}

 resource "aws_route_table_association" "PrivateRTassociation" {
  subnet_id = aws_subnet.privatesubnets.id
  route_table_id = aws_route_table.PrivateRT.id
}
