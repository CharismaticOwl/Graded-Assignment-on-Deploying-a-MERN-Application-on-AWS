provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "assignment_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "assignment_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.assignment_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_subnet_az
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.assignment_vpc.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.private_subnet_az
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "assignment_IG" {
  vpc_id = aws_vpc.assignment_vpc.id
}

resource "aws_eip" "NAT_EIP" {
  domain = "vpc"
}

resource "aws_nat_gateway" "assignment_NAT" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id     = aws_subnet.private_subnet.id
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.assignment_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.assignment_IG.id
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.assignment_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.assignment_NAT.id
  }
}

resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_security_group" "web_server_SG" {
  name = "SG for web server"
  description = "SG for web server"
  vpc_id = aws_vpc.assignment_vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["223.233.80.197/32"]
  }

  tags = {
    Name = "web_server_SG"
  }
}

resource "aws_security_group" "database_server_SG" {
  name = "SG for database server"
  description = "SG for database server"
  vpc_id = aws_vpc.assignment_vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["223.233.80.197/32"]
  }

  tags = {
    Name = "database_server_SG"
  }
}

resource "aws_instance" "web_server" {
  ami = var.AMI
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_subnet.id
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.web_server_SG.id]
  tags = {
    Name = "web_server"
  }
}

resource "aws_instance" "database" {
  ami = var.AMI
  instance_type = var.instance_type
  key_name = "ec2"
  subnet_id = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.database_server_SG.id]
  tags = {
    Name = "database"
  }
}