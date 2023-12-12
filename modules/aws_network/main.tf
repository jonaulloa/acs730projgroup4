

#----------------------------------------------------------
# ACS730 - Final Project 
#----------------------------------------------------------

# Step 1 - Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
}

# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}Vpc"
    }
  )
}


# Add provisioning of the public subnetin the default VPC
resource "aws_subnet" "public_subnet" {
  #count             = var.env == "prod" ? 0 : length(var.public_cidr_blocks)
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}PublicSubnet"
    }
  )
}

# Add provisioning of the private subnetin the default VPC
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}PrivateSubnet"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
#count = var.env == "prod" ? 0 : 1
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}Igw"
    }
  )
}

# Create Elastic IP
resource "aws_eip" "nat_gateway_eip" {
#count = var.env == "prod" ? 0 : 1
  domain = "vpc"
  tags = {
    Name = "${var.env}NatEip"
  }
}

# Create NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     =  aws_subnet.public_subnet[1].id
  tags = {
    Name = "${var.env}Nat"
  }
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  
  tags = {
    Name = "${var.prefix}PublicRoutes"
  }
}

# Route table to route add default gateway pointing to NAT Gateway (NAT)
resource "aws_route_table" "private_routes" {
#count = var.env == "prod" ? 0 : 1
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  
  tags = {
    Name = "${var.prefix}PrivateRoutes"
  }
}

# Associate subnets with the custom public route table
resource "aws_route_table_association" "public_routes_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  #route_table_id = aws_route_table.public_routes[0].id
  route_table_id = aws_route_table.public_routes.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Associate subnets with the custom private route table
resource "aws_route_table_association" "private_routes_table_association" {
 #count          = var.env == "prod" ? 0 : length(var.private_cidr_blocks)
  count          = length(aws_subnet.private_subnet[*].id)
  #route_table_id = aws_route_table.private_routes[0].id
  route_table_id = aws_route_table.private_routes.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
