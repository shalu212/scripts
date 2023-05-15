#Update Provider
#Aws As Our Provider

provider "aws"{
region = "us-east-1"
access_key = "XXXXXXXXXXXXX"
secret_key = "XXXXXXXXXXXXXXXXXX"
}

# Creating VPC
resource "aws_vpc" "my_vpc" {
cidr_block = "192.168.0.0/16"
instance_tenancy = "default"
tags = {
Name = "my_vpc"
}
}

# Creating Internet Gateway
 resource "aws_internet_gateway" "demogateway"{
 vpc_id = aws_vpc.my_vpc.id
 }

# Create subnet
resource "aws_subnet" "my_subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "192.168.128.0/18"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
  Name = "Public-subnet"
}
}

# Create subnet
resource "aws_subnet" "my_subnet2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "192.168.0.0/17"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
  Name = "Public-subnet2"
}
}

# Create subnet
resource "aws_subnet" "my_subnet3" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "192.168.192.0/18"
  availability_zone = "us-east-1a"
  tags = {
  Name = "Private-subnet"
}
}

# Create security group
resource "aws_security_group" "my_security_group" {
  name        = "web_security_group"
  description = "Allow inbound traffic on port 80"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances
resource "aws_instance" "my_instance1" {
  ami           = "ami-0889a44b331db0194"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  key_name      = "authentication"
  subnet_id     = aws_subnet.my_subnet1.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true
  tags = {
  Name                        = "My Public Instance1"
}
}

resource "aws_instance" "my_instance2" {
  ami           = "ami-0889a44b331db0194"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  key_name                    = "authentication"
  subnet_id     = aws_subnet.my_subnet2.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true
  tags                        = {
  Name                        = "My Public Instance 2"
}
}

# Create load balancer
resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]
}

resource "aws_lb_target_group" "target-elb" {
  name = "ALB-TG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.my_vpc.id
}


# Attach instances to the load balancer
resource "aws_lb_target_group_attachment" "my_lb_attachment1" {
  target_group_arn = aws_lb_target_group.target-elb.arn
  target_id        = aws_instance.my_instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my_lb_attachment2" {
  target_group_arn = aws_lb_target_group.target-elb.arn
  target_id        = aws_instance.my_instance2.id
  port             = 80
}
