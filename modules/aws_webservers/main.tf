

#----------------------------------------------------------
# ACS730 - Week 3 - Terraform Introduction
#
# Build EC2 Instances
#
#----------------------------------------------------------

#  Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "terraform_remote_state" "tf_remote_state_prod" {
  backend = "s3"
  config = {
    bucket = "acs730-final-test"
    key    = "prod/network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
}

# Reference subnet provisioned by 01-Networking 
resource "aws_instance" "PrivateVM" {
  count                       = length(data.terraform_remote_state.tf_remote_state_prod.outputs.private_subnet_ids)
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  
  subnet_id                   = data.terraform_remote_state.tf_remote_state_prod.outputs.private_subnet_ids[count.index]
  security_groups             = [aws_security_group.PrivateSg.id]
  associate_public_ip_address = false
  #user_data                   = templatefile("${path.module}/install_httpd.sh.tpl", { "env" = var.env })

  root_block_device {
    encrypted = true
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}Vm${count.index+5}"
    }
  )
}

# Create Amazon Linux EC2 instances in a default VPC
resource "aws_instance" "WebServerVM" {
  #count                       = var.env == "prod" ? 0 : 1
  count                       = length(data.terraform_remote_state.tf_remote_state_prod.outputs.public_subnet_ids)
  #count                       = 2
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  #${lower(var.prefix)}
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.tf_remote_state_prod.outputs.public_subnet_ids[count.index]
  security_groups             = [aws_security_group.WebServerSg.id]
  associate_public_ip_address = true
  #checkVM1 = subnet_id == data.terraform_remote_state.tf_remote_state_prod.outputs.public_subnet_ids[0] ? templatefile("${path.module}/install_httpd.sh.tpl", { "env" = var.env }) : null
  user_data                   = templatefile("${path.module}/install_httpd.sh.tpl", { "env" = var.env })
  
  #check = subnet_id == data.terraform_remote_state.tf_remote_state_prod.outputs.public_subnet_ids[1] ? {
  provisioner "file" {
    source = "../../prod/webservers/.keypair"
    destination = "/home/ec2-user/.ssh/prod"
    connection {
      type = "ssh"
      user = "ec2-user"
      #private_key = file("${var.prefix}")
      private_key = file("../../prod/webservers/.keypair/${lower(var.prefix)}")
      host = self.public_ip
    }
  }
  
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}WebServerVm${count.index}"
      "Owner" = count.index >= 2 ? "Group4" : "Grp4"
    }
  )
}


# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = var.prefix
  public_key = file("../../prod/webservers/.keypair/${var.prefix}.pub")
}

# Elastic IP
resource "aws_eip" "static_eip" {
  #count    = var.env == "prod" ? 0 : 1
  instance = aws_instance.WebServerVM[0].id
  #instance = aws_instance.WebServerVM.id
  tags     = merge(local.default_tags,
    {
      "Name" = "${var.prefix}Eip"
    }
  )
}