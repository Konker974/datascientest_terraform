variable "namespace" {
  description = "L'espace de noms de projet à utiliser pour la dénomination unique des ressources"
  default     = "dst"
  type        = string
}

variable "region" {
  description = "AWS région"
  default     = "eu-west-3"
  type        = string
}

variable "access_key" {
  type     = string
  nullable = false
}

variable "secret_key" {
  type     = string
  nullable = false
}

variable "key_name" {
  description = "Nom de la key pair EC2 existante (optionnel)"
  type        = string
  default     = "dst"
}

variable "ebs_size" {
  description = "Taille du volume EBS additionnel en Go"
  type        = number
  default     = 10
}

variable "mysql_version" {
  description = "Version du moteur MySQL RDS"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Type d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nom de la base WordPress"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Utilisateur base WordPress"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Mot de passe base WordPress"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Stockage alloue initial RDS (Go)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Stockage max autoscaling RDS (Go)"
  type        = number
  default     = 100
}

variable "db_backup_retention_days" {
  description = "Retentions des backups automatiques RDS"
  type        = number
  default     = 1
}

variable "db_deletion_protection" {
  description = "Protection contre suppression de l'instance RDS"
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Ignorer le snapshot final a la destruction"
  type        = bool
  default     = true
}