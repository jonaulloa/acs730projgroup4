# Module to deploy basic networking 
module "vpc-prod" {
  source        = "../../modules/aws_webservers"
  instance_type = var.instance_type
  default_tags  = var.default_tags
  prefix        = var.prefix
  env           = var.env
}
