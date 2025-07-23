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
        cidr_blocks =["0.0.0.0/0"] # Allow HTTP from anywhere consider restricting this in production
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks =["0.0.0.0/0"]# Allow SSH from anywhere, consider restricting this in production
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic consider restricting this in production
    }
    tags = {
        Name = "${var.env_prefix}-security-group"
    }
}

data "aws_ami" "myapp_ami" {
  most_recent = true
  owners      = ["amazon"] # Use Amazon's official AMIs
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Example for Amazon Linux 2, adjust as needed
  }    
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]     
  
} 
}

resource "aws_instance" "myapp_instance" {
  ami           = data.aws_ami.myapp_ami.id # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.myapp_subnet.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
    tags = {
        Name = "${var.env_prefix}-instance"
    }
}
output "vpc_id" {    
  value = aws_vpc.myapp_vpc.id    # Output the VPC ID  
}
output "subnet_id" {
  value = aws_subnet.myapp_subnet.id # Output the Subnet ID
}
output "instance_id" {
  value = aws_instance.myapp_instance.id # Output the Instance ID
} 
output "myapp_ami_id" {
  value = data.aws_ami.myapp_ami.id # Output the AMI ID
}      
output "instance_public_ip" {
  value =  aws_instance.myapp_instance.public_ip # Output the Instance Public IP
}    

