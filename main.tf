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
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cdr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_blocks
  availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet"
    }
}