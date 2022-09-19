provider "aws" {
    region  = "us-west-1"
    access_key = 
    secret_key = 
}

 #1. Creating the VPC
 resource "aws_vpc" "project_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "production"
  }
 }

 #2. Creating the Internet Gateway
 resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.project_vpc.id


}
#3. create custom route table
resource "aws_route_table" "project-route-table" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0" #all traffic is going to be sent to the default internet gateway
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id #makes it so that our traffic from the subnet we create can get out to the internet
  }

  tags = {
    Name = "route-table-production"
  }
}
#4. create a subnet
resource "aws_subnet" "first-subnet" {
  vpc_id = aws_vpc.project_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1a"

  tags = {
    "name" = "project-subnet"
  }
}
#5. associate route table with subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.first-subnet.id
  route_table_id = aws_route_table.project-route-table.id
}
#6. create a security group
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    description      = "HTTPS traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "SSH traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  

  }
   ingress {
    description      = "HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}

#7.create a network interface
 resource "aws_network_interface" "web-server-int"{
   subnet_id       = aws_subnet.first-subnet.id
   private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

 }
#8. assigning an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-int.id
  associate_with_private_ip = "10.0.1.50" #this is the IP we are passing from the network interface
  depends_on = [aws_internet_gateway.gw]
}
#9. create our ubuntu server
resource "aws_instance" "web-server-instance" {
  ami = "ami-067f8db0a5c2309c0"
  instance_type = "t2.micro"
  availability_zone = "us-west-1a"
  key_name = "main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-int.id
  }
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your very first web server > /var/www/html'
                EOF
    tags = {
      Name = "web-server"
    
    }
  }

