# Security Group
resource "aws_security_group" "PrivateSg" {
  name        = "allow_ssh_prod"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.tf_remote_state_prod.outputs.vpc_id

  ingress {
    description      = "SSH from WebServerVM2"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.1.2.0/24"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}WebServerSg"
    }
  )
}

resource "aws_security_group" "WebServerSg" {
  name        = "allow_http_ssh_webserver"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.tf_remote_state_prod.outputs.vpc_id
  
  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    #cidr_blocks      = ["10.1.0.0/16","10.10.0.0/16"]
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from everywhere"
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
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}WebServerSg"
    }
  )
}
