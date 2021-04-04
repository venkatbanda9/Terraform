provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAIO6QH5WT3AHSBACQ"
  secret_key = "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"
}

terraform {
    required_version = ">= 0.12.17"

}

resource "aws_vpc" "newvpc" {
  cidr_block       = "20.20.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "newvpc"
  }
}

resource "aws_subnet" "oursubnet" {
  vpc_id     = aws_vpc.newvpc.id
  cidr_block = "20.20.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "oursubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.newvpc.id

  tags = {
    Name = "igw"
  }
}


resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.newvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

   tags = {
    Name = "rt1"
  }
}
resource "aws_route_table_association" "subas" {
  subnet_id      = aws_subnet.oursubnet.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_security_group" "newtfsg" {
  # ... other configuration ...
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.newvpc.id
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
}
resource "aws_instance" "AMILINUX" {
  ami           = "ami-08e0ca9924195beba"
  instance_type = "t2.micro"
  key_name	= "python"
  associate_public_ip_address = true
  subnet_id     = aws_subnet.oursubnet.id
  vpc_security_group_ids = [aws_security_group.newtfsg.id]

  tags = {
    Name = "AMILINUX"
  }
}
