# Add output variables
output "public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
  #value = aws_subnet.private_subnet[0]
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_routes" {
  value = aws_route_table.public_routes[*].id
}

output "private_routes" {
  value = aws_route_table.private_routes[*].id
  #value = aws_subnet.private_subnet[0]
}
