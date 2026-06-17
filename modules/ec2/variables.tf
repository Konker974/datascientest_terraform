###############################################################################
# Réseau
###############################################################################

variable "public_subnet_id" {
  description = "ID du subnet public dans lequel deployer l'instance EC2"
  type        = string
}

variable "ec2_sg_id" {
  description = "ID du Security Group a attacher a l'instance EC2"
  type        = string
}

variable "namespace" {
  type = string
}

variable "key_name" {
  description = "Nom de key pair EC2 existante (optionnel)"
  type        = string
  default     = null
}

variable "db_name" {
  description = "Nom de la base WordPress"
  type        = string
}

variable "db_username" {
  description = "Utilisateur de la base WordPress"
  type        = string
}

variable "db_password" {
  description = "Mot de passe de la base WordPress"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Endpoint RDS principal (hostname)"
  type        = string
}