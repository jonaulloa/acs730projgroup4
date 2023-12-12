

#----------------------------------------------------------
# ACS730 - Lab 3 - Terraform Introduction
#
# Build Fault Tolerant Static Web Site
#
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
#count = var.env == "prod" ? 0 : 1
  #allocation_id = aws_eip.nat_gateway_eip[0].id
  #subnet_id     =  aws_subnet.public_subnet[1].id
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     =  aws_subnet.public_subnet[1].id
  tags = {
    Name = "${var.env}Nat"
  }
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_routes" {
#count = var.env == "prod" ? 0 : 1
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    #gateway_id = aws_internet_gateway.igw[count.index].id
    gateway_id = aws_internet_gateway.igw.id
  }

  #newwww
  /*route {
    cidr_block = aws_vpc.main.id
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }*/
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
    #nat_gateway_id = aws_nat_gateway.nat[count.index].id
    #nat_gateway_id = var.env == "prod" ? "" : aws_nat_gateway.nat[0].id
    #nat_gateway_id = var.env == "prod" ? "" : aws_nat_gateway.nat.id
    nat_gateway_id = aws_nat_gateway.nat.id
    #vpc_peering_connection_id = var.env == "prod" ? aws_vpc_peering_connection.vpc_peering[0].id : ""
    #var.env == "prod" ? {vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id}
    #local = "10.10.0.0/16"
  }
  #newwww
  /*route {
    cidr_block = aws_vpc.main.id
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }*/
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
/*
# Use remote state to retrieve the data
data "terraform_remote_state" "tf_remote_state_daphne" {
  backend = "s3"
  config = {
    bucket = "acs730-final-test"
    key    = "prod/network/terraform.tfstate"
    region = "us-east-1"
  }
}*/
/*
resource "aws_vpc_peering_connection" "vpc_peering" {
  count         = var.env == "dev" ? 0 : 1
  #peer_owner_id = var.peer_owner_id
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = data.terraform_remote_state.tf_remote_state_daphne.outputs.vpc_id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between VPC Non Prod and VPC Prod"
  }
}*/

/*resource "aws_route_table_association" "public_rt_peering" {
count         = var.env == "dev" ? 0 : 1
  gateway_id     = aws_vpc_peering_connection.vpc_peering[0].id
  route_table_id = data.terraform_remote_state.tf_remote_state_daphne.outputs.public_routes[0]
}

resource "aws_route_table_association" "private_rt_peering" {
count         = var.env == "dev" ? 0 : 1
  gateway_id     = aws_vpc_peering_connection.vpc_peering[0].id
  #route_table_id = aws_route_table.private_routes[0].id
  route_table_id = data.terraform_remote_state.tf_remote_state_daphne.outputs.private_routes[0]
}*/
/*
# Create a route
resource "aws_route" "public_rt_peering" {
  count         = var.env == "dev" ? 0 : 1
  route_table_id            = data.terraform_remote_state.tf_remote_state_daphne.outputs.public_routes[0]
  destination_cidr_block    = var.private_cidr_blocks[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
}

# Create a route
resource "aws_route" "private_rt_peering" {
  count         = var.env == "dev" ? 0 : 1
  #route_table_id            = data.terraform_remote_state.tf_remote_state_daphne.outputs.private_routes[0]
  route_table_id            = aws_route_table.private_routes.id
  destination_cidr_block    = var.public_cidr_blocks[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
}*/
/*
resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_vpc_peering_connection.vpc_peering[0].id
  }
}

resource "aws_route_table" "route_table2" {
  vpc_id = data.terraform_remote_state.tf_remote_state_daphne.outputs.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_vpc_peering_connection.vpc_peering[0].id
  }
}*/