


# Custom Vpc
resource "aws_vpc" "prod-app-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "prod-app-vpc"
  }

}

# Internet gateway
resource "aws_internet_gateway" "prod-app" {
  vpc_id = aws_vpc.prod-app-vpc.id

  tags = {
    "Name" = "internet-gateway"
  }
}


# Elastic ip
resource "aws_eip" "elip" {
  instance = aws_instance.prod-app.id
  vpc      = true
  depends_on = [aws_internet_gateway.prod-app]
}




# Nat gateway1
resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.elip.id
  subnet_id     = aws_subnet.private-subnet1.id
  depends_on = [aws_internet_gateway.prod-app]

  tags = {
    Name = "gw NAT"
  }
}


# Nat gateway2
resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.elip.id
  subnet_id     = aws_subnet.private-subnet2.id
  depends_on = [aws_internet_gateway.prod-app]

  tags = {
    Name = "gw NAT"
  }
}

# Network interface






# Public Route table 
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.prod-app-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-app.id
  }


  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.prod-app.id
  }

  tags = {
    Name = "public-route"
  }
}



# Create subnet association 
resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "public-2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-route.id
}


# Public subnets
resource "aws_subnet" "public-subnet1" {
  vpc_id            = aws_vpc.prod-app-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "public-subnet1"
  }

}

resource "aws_subnet" "public-subnet2" {
  vpc_id            = aws_vpc.prod-app-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "public-subnet2"
  }

}



# Private subnet 
resource "aws_subnet" "private-subnet1" {
  vpc_id            = aws_vpc.prod-app-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    "Name" = "private-subnet1"
  }

}

resource "aws_subnet" "private-subnet2" {
  vpc_id            = aws_vpc.prod-app-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1d"

  tags = {
    "Name" = "private-subnet2"
  }

}



# Security group
resource "aws_security_group" "prod-app-sg" {
  name        = "prod-app-sg"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod-app-vpc.id

ingress {
  description      = "HTTPS"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
  description      = "SSH"
  from_port        = 22
  to_port          = 22
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
    Name = "allow_tls"
  }
}

# create  aws instance 
resource "aws_instance" "prod-app" {
  ami           = "ami-042e8287309f5df03"
  instance_type = "t2.micro"
  availability_zone = "us-east-1c"
  key_name          = "prod-key" 
  


  tags = {
    "Name" = "prod-app"
  }
}


output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.prod-app.public_ip
}

