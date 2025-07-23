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

resource "aws_route_table_association" "myapp_route_table_association" {
  subnet_id      = aws_subnet.myapp_subnet.id
  route_table_id = aws_route_table.myapp_route_table.id
}

resource "aws_security_group" "myapp_sg" {
  vpc_id = aws_vpc.myapp_vpc.id
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = "0.0.0.0/0" # Allow HTTP from anywhere consider restricting this in production
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = "0.0.0.0/0" # Allow SSH from anywhere, consider restricting this in production
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ""
    }
    tags = {
        Name = "${var.env_prefix}-security-group"
    }
}
