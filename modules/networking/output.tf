###############################################################################
# outputs.tf (inline)
###############################################################################

output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID du subnet public (EC2)"
  value       = aws_subnet.public.id
}

output "private_subnet_ids" {
  description = "IDs des subnets prives (RDS Multi-AZ)"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "sg_ec2_id" {
  description = "ID du Security Group EC2 WordPress"
  value       = aws_security_group.ec2_wordpress.id
}

output "sg_rds_id" {
  description = "ID du Security Group RDS MySQL"
  value       = aws_security_group.rds_mysql.id
}

output "availability_zones" {
  description = "AZ utilisees"
  value = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
  ]
}
