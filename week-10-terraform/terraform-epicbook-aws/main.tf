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
resource "aws_vpc" "tf_epicbook_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "tf_epicbook_public_subnet" {
  vpc_id                  = aws_vpc.tf_epicbook_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "af-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "tf_epicbook_private_subnet_1" {
  vpc_id            = aws_vpc.tf_epicbook_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "af-south-1a"

  tags = {
    Name = "terraform-private-subnet"
  }
}

resource "aws_subnet" "tf_epicbook_private_subnet_2" {
  vpc_id            = aws_vpc.tf_epicbook_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "af-south-1b"

  tags = {
    Name = "terraform-private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tf_epicbook_vpc.id

  tags = {
    Name = "terraform-igw"
  }
}

# Route Table
resource "aws_route_table" "tf_epicbook_public_rt" {
  vpc_id = aws_vpc.tf_epicbook_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "tf_epicbook_public_rta" {
  subnet_id      = aws_subnet.tf_epicbook_public_subnet.id
  route_table_id = aws_route_table.tf_epicbook_public_rt.id
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "terraform-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.tf_epicbook_vpc.id

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

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "terraform-db-sg"
  description = "Allow MySQL access from EC2"
  vpc_id      = aws_vpc.tf_epicbook_vpc.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-db-sg"
  }
}


# EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami                         = "ami-058c1bfce526cdcc2"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.tf_epicbook_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = "dmi-key"
  user_data                   = file("./user_data.sh")

  tags = {
    Name = "terraform-ubuntu-vm"
  }
}

# Database Configuration
resource "aws_db_instance" "epicbook_db" {
  identifier       = "epicbook-db"
  allocated_storage    = 20
  db_name              = "epicbookdb"
  engine               = "mysql"
  engine_version       = "8.4"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "booktoken"
  parameter_group_name = "default.mysql8.4"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.epicbook_db_subnet_group.id
}

resource "aws_db_subnet_group" "epicbook_db_subnet_group" {
  name       = "epicbook-db-subnet-group"
  subnet_ids = [aws_subnet.tf_epicbook_private_subnet_1.id, aws_subnet.tf_epicbook_private_subnet_2.id]
  tags = {
    Name = "epicbook-db-subnet-group"
  }
  
}

# Output Public IP
output "ec2_public_ip" {
  value       = aws_instance.ec2_instance.public_ip
  description = "The public IP address of the EC2 instance"
}

# Output Database Endpoint
output "db_endpoint" {
  value       = aws_db_instance.epicbook_db.endpoint
  description = "The endpoint of the RDS database instance"
}