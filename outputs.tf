output "wordpress_public_ip" {
  description = "IP publique du serveur WordPress"
  value       = module.ec2.public_ip
}

output "wordpress_url_http" {
  description = "URL HTTP d'acces a WordPress"
  value       = "http://${module.ec2.public_dns}"
}

output "wordpress_url_https" {
  description = "URL HTTPS d'acces au serveur web (si TLS configure sur l'instance)"
  value       = "https://${module.ec2.public_dns}"
}

output "ec2_availability_zone" {
  description = "AZ de l'instance EC2"
  value       = module.ec2.availability_zone
}

output "ebs_volume_id" {
  description = "ID du volume EBS"
  value       = module.ebs.volume_id
}

output "rds_primary_endpoint" {
  description = "Endpoint principal RDS"
  value       = module.rds.primary_endpoint
}

output "rds_replica_endpoint" {
  description = "Endpoint replica RDS"
  value       = module.rds.replica_endpoint
}
