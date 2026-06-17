###############################################################################
# modules/ec2/outputs.tf
###############################################################################

output "instance_id" {
  description = "ID de l'instance EC2 WordPress"
  value       = aws_instance.ec2_public.id
}

output "instance_arn" {
  description = "ARN de l'instance EC2 WordPress"
  value       = aws_instance.ec2_public.arn
}

output "public_ip" {
  description = "IP publique de l'instance EC2 (acces HTTP/HTTPS/SSH)"
  value       = aws_instance.ec2_public.public_ip
}

output "public_dns" {
  description = "DNS public de l'instance EC2"
  value       = aws_instance.ec2_public.public_dns
}

output "availability_zone" {
  description = "Zone de disponibilite de l'instance EC2"
  value       = aws_instance.ec2_public.availability_zone
}

output "ami_id" {
  description = "ID de l'AMI Amazon Linux 2 utilisee"
  value       = data.aws_ami.amazon_linux2.id
}

output "ami_name" {
  description = "Nom de l'AMI Amazon Linux 2 utilisee"
  value       = data.aws_ami.amazon_linux2.name
}
