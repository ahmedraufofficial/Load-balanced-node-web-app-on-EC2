provider "aws" {
  region  = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

#creating vpc
resource "aws_vpc" "production_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

#internet gateway
resource "aws_internet_gateway" "production_gateway" {
  vpc_id = aws_vpc.production_vpc.id
}

#route Table
resource "aws_route_table" "production_route_table" {
  vpc_id = aws_vpc.production_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.production_gateway.id
  }

  tags = {
    Name = "production_route_table"
  }
}

#subnet 
resource "aws_subnet" "production_subnet" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zproduction_ip = "us-east-1a"

  tags = {
    Name = "production_subnet"
  }
}

#configure subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.production_subnet.id
  route_table_id = aws_route_table.production_route_table.id
}

#security Group allow ssh and http/s
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.production_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "production_sg"
  }
}

#network interface with ip from subnet
resource "aws_network_interface" "production_nic" {
  subnet_id       = aws_subnet.production_subnet.id
  private_ips     = ["10.0.1.49"]
  security_groups = [aws_security_group.allow_web.id]

}

#create elastic ip to attach to instance
resource "aws_eip" "production_ip" {
  vpc                       = true
  network_interface         = aws_network_interface.production_nic.id
  associate_with_private_ip = "10.0.1.49"
  depends_on                = [aws_internet_gateway.production_gateway]
}

output "server_public_ip" {
  value = aws_eip.production_ip.public_ip
}

#create instance
resource "aws_instance" "web-server-instance" {
  ami               = "ami-08c40ec9ead489470"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "bespin"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.production_nic.id
  }

  tags = {
    Name = "production_instance"
  }
}


