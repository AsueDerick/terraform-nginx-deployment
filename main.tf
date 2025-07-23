provider "aws" {
  
}

variable "vpc_cdr_block" {
  description = "CIDR block for the VPC"
  type        = string 
  
}
variable "subnet_cidr_blocks" {
  description = "CIDR block for the subnet"
  type        = string 
  
}
variable "avail_zone" {
  description = "Availability Zone for the subnet"
  type        = string 
  
}
variable "env_prefix" {
  description = "Environment prefix for resource naming"
  type        = string 
  
}
resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cdr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}
resource "aws_subnet" "myapp_subnet" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = var.subnet_cidr_blocks
  availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id
    tags = {
        Name = "${var.env_prefix}-internet-gateway"
    }
}

resource "aws_route_table" "myapp_route_table" {
  vpc_id = aws_vpc.myapp_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp_igw.id
    }
    tags = {
        Name = "${var.env_prefix}-route-table"
    }
}

