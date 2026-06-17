variable "namespace" {
  type = string
}
###############################################################################
# Reseau
###############################################################################

variable "private_subnet_ids" {
  description = "IDs des subnets prives pour le DB Subnet Group (1 par AZ minimum – eu-west-3a et eu-west-3b)"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "Au moins 2 subnet IDs dans 2 AZ differentes sont requis."
  }
}

variable "rds_sg_id" {
  description = "ID du Security Group autorisant MySQL (3306) vers les instances RDS"
  type        = string
}

###############################################################################
# Moteur
###############################################################################

variable "mysql_version" {
  description = "Version du moteur MySQL"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Type d'instance RDS (primary et replica)"
  type        = string
  default     = "db.t3.micro"
}

###############################################################################
# Base de donnees (primary uniquement)
###############################################################################

variable "db_name" {
  description = "Nom de la base de donnees WordPress"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Nom d'utilisateur administrateur"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Mot de passe administrateur (min. 12 caracteres)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 12
    error_message = "Le mot de passe doit contenir au moins 12 caracteres."
  }
}

###############################################################################
# Stockage
###############################################################################

variable "allocated_storage" {
  description = "Taille initiale du stockage en Go (primary)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Taille maximale pour l'autoscaling du stockage en Go (0 = desactive)"
  type        = number
  default     = 100
}

###############################################################################
# Backups & protection
###############################################################################

variable "backup_retention_days" {
  description = "Nombre de jours de retention des backups automatiques (min. 1 pour activer la replica)"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "La retention doit être comprise entre 1 et 35 jours. Une valeur >= 1 est obligatoire pour les Read Replicas."
  }
}

variable "deletion_protection" {
  description = "Protection contre la suppression accidentelle (recommande en prod)"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Ne pas creer de snapshot final lors de la destruction (false recommande en prod)"
  type        = bool
  default     = true
}

