terraform {
  backend "s3" {
    bucket = "acs730-final-test"
    key    = "prod/webservers/terraform.tfstate"
    region = "us-east-1"
  }
}