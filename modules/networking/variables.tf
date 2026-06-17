###############################################################################
# variables.tf (inline pour ce fichier unique)
###############################################################################
variable "namespace" {
  type = string
}

variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr" {
  description = "CIDR block du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR du subnet public (EC2)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_a" {
  description = "CIDR du subnet prive A – eu-west-3a (RDS Primary)"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_subnet_cidr_b" {
  description = "CIDR du subnet prive B – eu-west-3b (RDS Standby)"
  type        = string
  default     = "10.0.11.0/24"
}

variable "ssh_allowed_cidrs" {
  description = "Liste des CIDR autorises à se connecter en SSH (restreindre en prod)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # ← remplacer par votre IP publique en production
}