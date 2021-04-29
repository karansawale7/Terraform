#AWS Access

provider "aws" { 
region = var.region 
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.aws_cidr_vpc
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "prod-vpc"
  }
}

# Creating IGW 
resource "aws_internet_gateway" "mwiki_igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "prod-IG"
    }
}

# Grant the VPC internet access on its main route table

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.mwiki_igw.id
    }
}

resource "aws_route_table_association" "PublicAZ" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}


resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.aws_cidr_subnet1
  availability_zone = element(var.azs, 1)

  tags = {
    Name = "PublicSubnet"
  }
}


resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.aws_cidr_subnet2
  availability_zone = element(var.azs, 2)
  tags = {
    Name = "PrivateSubnet"
  }
}


resource "aws_security_group" "mwiki_sg" {
  name = "Prod-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 22 
    to_port  = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port = 80
    to_port  = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3306
    to_port  = 3306
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port  = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "tls_private_key" "mwiki_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.keyname
  public_key = tls_private_key.mwiki_key.public_key_openssh
}



# Launch the instance
resource "aws_instance" "webserver" {
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.mwiki_sg.id]
  subnet_id     = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = lookup(var.aws_tags,"webserver")
    group = "web"
  }
}

resource "aws_instance" "dbserver" {
  depends_on = [aws_security_group.mwiki_sg]
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.mwiki_sg.id]
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = lookup(var.aws_tags,"dbserver")
    group = "db"
  }
}


resource "aws_elb" "mw_elb" {
  name = "prod-ELB"
  subnets         = [aws_subnet.public_subnet.id]
  security_groups = [aws_security_group.mwiki_sg.id]
  instances = [aws_instance.webserver.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

output "pem" {
        value = ["tls_private_key.mwiki_key.private_key_pem"]
}

output "address" {
  value = aws_elb.mw_elb.dns_name
}
