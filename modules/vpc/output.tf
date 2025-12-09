output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.verdethos_vpc.id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.verdethos_igw.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = [for nat in aws_nat_gateway.nat : nat.id]
}
