###############################################################################
# modules/rds/outputs.tf
###############################################################################

###############################################################################
# Instance Primary (eu-west-3a) – WordPress ecrit ici
###############################################################################

output "primary_instance_id" {
  description = "Identifiant de l'instance RDS primary"
  value       = aws_db_instance.primary.id
}

output "primary_endpoint" {
  description = "Endpoint complet de la primary (host:port) – à utiliser dans wp-config.php"
  value       = aws_db_instance.primary.endpoint
}

output "primary_host" {
  description = "Hostname de la primary seul (sans le port)"
  value       = aws_db_instance.primary.address
}

output "primary_port" {
  description = "Port MySQL de la primary"
  value       = aws_db_instance.primary.port
}

output "primary_availability_zone" {
  description = "AZ de l'instance primary"
  value       = aws_db_instance.primary.availability_zone
}

###############################################################################
# Instance Replica (eu-west-3b) – lecture seule
###############################################################################

output "replica_instance_id" {
  description = "Identifiant de l'instance RDS replica"
  value       = aws_db_instance.replica.id
}

output "replica_endpoint" {
  description = "Endpoint complet de la replica (host:port) – lecture seule"
  value       = aws_db_instance.replica.endpoint
}

output "replica_host" {
  description = "Hostname de la replica seul (sans le port)"
  value       = aws_db_instance.replica.address
}

output "replica_availability_zone" {
  description = "AZ de l'instance replica"
  value       = aws_db_instance.replica.availability_zone
}

###############################################################################
# Informations communes
###############################################################################

output "db_name" {
  description = "Nom de la base de donnees WordPress"
  value       = aws_db_instance.primary.db_name
}

output "db_username" {
  description = "Nom d'utilisateur administrateur"
  value       = aws_db_instance.primary.username
  sensitive   = true
}

output "db_subnet_group_name" {
  description = "Nom du DB Subnet Group"
  value       = aws_db_subnet_group.wordpress.name
}

output "db_engine_version" {
  description = "Version MySQL effectivement deployee"
  value       = aws_db_instance.primary.engine_version_actual
}

output "db_instance_class" {
  description = "Type d'instance utilise (primary et replica)"
  value       = aws_db_instance.primary.instance_class
}

output "db_storage_encrypted" {
  description = "Indique si le stockage est chiffre"
  value       = aws_db_instance.primary.storage_encrypted
}
