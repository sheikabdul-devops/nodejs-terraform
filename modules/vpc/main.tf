# Create a VPC

resource "aws_vpc" "myapp" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
        Name = "myapp-aws-vpc"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.myapp.id
}

data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_subnet" "main" {
  vpc_id = aws_vpc.myapp.id
  cidr_block = var.main_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
        Name = "Subnet main"
    }

}

resource "aws_subnet" "secondary" {
  vpc_id = aws_vpc.myapp.id
  cidr_block = var.secondary_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
        Name = "Subnet secondary"
    }

}

resource "aws_route_table" "eu-west" {
    vpc_id = aws_vpc.myapp.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags = {
        Name = "subnet RT"
    }
}

resource "aws_route_table_association" "eu-west-main" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.eu-west.id
}


resource "aws_route_table_association" "eu-west-secondary" {
    subnet_id = aws_subnet.secondary.id
    route_table_id = aws_route_table.eu-west.id
}

output "vpc_id" {
  value = aws_vpc.myapp.id
}

output "vpc_cidr" {
  value = aws_vpc.myapp.cidr_block
}

output "terraform_ip" {
  value = var.terraform_ip
}

output "subnet_ids" {
  value = [aws_subnet.main.id,aws_subnet.secondary.id]
}


