terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider
provider "aws" {
  region = "af-south-1"
  profile = "shared"
}

# VPC
resource "aws_vpc" "terraform_aws_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "terraform_public_subnet" {
  vpc_id                  = aws_vpc.terraform_aws_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "af-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "terraform_private_subnet" {
  vpc_id            = aws_vpc.terraform_aws_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "af-south-1b"

  tags = {
    Name = "terraform-private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform_aws_vpc.id

  tags = {
    Name = "terraform-igw"
  }
}

# Route Table
resource "aws_route_table" "terraform_public_rt" {
  vpc_id = aws_vpc.terraform_aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "terraform_public_rta" {
  subnet_id      = aws_subnet.terraform_public_subnet.id
  route_table_id = aws_route_table.terraform_public_rt.id
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "terraform-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.terraform_aws_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-ec2-sg"
  }
}

# EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami                         = "ami-058c1bfce526cdcc2"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.terraform_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = "dmi-key"

  tags = {
    Name = "terraform-ubuntu-vm"
  }
}

# Output Public IP
output "ec2_public_ip" {
  value       = aws_instance.ec2_instance.public_ip
  description = "The public IP address of the EC2 instance"
}