# modules/networking/outputs.tf
# These outputs become INJECTABLE dependencies for other modules

output "vpc_id" {
  description = "VPC ID — inject into other modules"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs — inject into EKS, Lambda, RDS"
  value       = aws_subnet.private[*].id
}