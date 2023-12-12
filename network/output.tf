output "public_subnet_ids" {
  value = module.vpc-prod.public_subnet_id
}

output "private_subnet_ids" {
  value = module.vpc-prod.private_subnet_id
}

output "vpc_id" {
  value = module.vpc-prod.vpc_id
}

output "public_routes" {
  value = module.vpc-prod.public_routes
}

output "private_routes" {
  value = module.vpc-prod.private_routes
  #value = aws_subnet.private_subnet[0]
}