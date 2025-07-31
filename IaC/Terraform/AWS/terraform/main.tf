terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# Create a VPC
resource "aws_vpc" "migration_example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Migration_VPC"
  }
}


resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.migration_example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Main"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.migration_example.id
  tags = {
    Name = "Migration Internet Gateway"
  }

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.migration_example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id

}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  vpc_id      = aws_vpc.migration_example.id
  description = "Allow inbound HTTP and SSH traffic"

  tags = {
    Name = "Migration Lab Security Group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Name = "sgrule_allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

  tags = {
    Name = "sgrule_allow_ssh"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # All ports

  tags = {
    Name = "sgrule_allow_all_outgoing"
  }
}

resource "aws_instance" "migration_vm" {
  ami                         = "ami-01f23391a59163da9" # Ubuntu 24.04 LTS AMI in eu-west-1
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = true
  depends_on                  = [aws_internet_gateway.gw]

  # Use cloud-config to provision the instance
  user_data = file("${path.module}/../scripts/cloud-config.yaml")

  tags = {
    Name = "ec2-migration-source"
  }


}
