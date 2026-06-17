provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
# appel du module networking
module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

# appel du module ec2
module "ec2" {
  source           = "./modules/ec2"
  namespace        = var.namespace
  public_subnet_id = module.networking.public_subnet_id
  ec2_sg_id        = module.networking.sg_ec2_id
  key_name         = var.key_name

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  db_host     = module.rds.primary_host
}

# appel du module ebs
module "ebs" {
  source            = "./modules/ebs"
  namespace         = var.namespace
  ebs_size          = var.ebs_size
  availability_zone = module.ec2.availability_zone
  instance_id       = module.ec2.instance_id
}

# appel du module rds
module "rds" {
  source             = "./modules/rds"
  namespace          = var.namespace
  private_subnet_ids = module.networking.private_subnet_ids
  rds_sg_id          = module.networking.sg_rds_id
  mysql_version      = var.mysql_version
  db_instance_class  = var.db_instance_class
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  backup_retention_days = var.db_backup_retention_days
  deletion_protection   = var.db_deletion_protection
  skip_final_snapshot   = var.db_skip_final_snapshot
}