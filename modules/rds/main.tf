###############################################################################
# modules/rds/main.tf
# Déploiement RDS MySQL sur 2 instances explicites dans 2 AZ différentes
# via aws_db_instance (primary + replica).
###############################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

###############################################################################
# DB Subnet Group
# Doit couvrir les 2 AZ pour que RDS puisse placer chaque instance
###############################################################################

resource "aws_db_subnet_group" "wordpress" {
  name        = "${var.namespace}-db-subnet-group"
  description = "Subnet group RDS WordPress euwest3a et euwest3b"
  subnet_ids  = var.private_subnet_ids # [subnet_3a_id, subnet_3b_id]

  tags = {
    Name = "${var.namespace}-db-subnet-group"
  }
}

###############################################################################
# Parameter Group MySQL 8.0 (partagé par les 2 instances)
###############################################################################

resource "aws_db_parameter_group" "wordpress" {
  name        = "${var.namespace}-mysql8"
  family      = "mysql8.0"
  description = "Parameter group MySQL 8.0 pour WordPress"

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "long_query_time"
    value        = "2"
    apply_method = "immediate"
  }

  tags = {
    Name = "${var.namespace}-mysql8-params"
  }
}

###############################################################################
# Instance RDS Primary – eu-west-3a
###############################################################################

resource "aws_db_instance" "primary" {
  identifier     = "${var.namespace}-db-primary"
  engine         = "mysql"
  engine_version = var.mysql_version
  instance_class = var.db_instance_class

  # Stockage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Base de données
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Réseau – subnet group + SG + AZ explicite
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [var.rds_sg_id]
  availability_zone      = data.aws_availability_zones.available.names[0] # eu-west-3a
  publicly_accessible    = false

  # Pas de multi_az ici : la 2ème instance est gérée explicitement ci-dessous
  multi_az = false

  parameter_group_name = aws_db_parameter_group.wordpress.name

  # Backups (obligatoire pour activer la Read Replica)
  backup_retention_period = var.backup_retention_days
  backup_window           = "02:00-03:00"
  maintenance_window      = "mon:03:00-mon:04:00"
  copy_tags_to_snapshot   = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.namespace}-primary-final-snapshot"

  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.namespace}-db-primary"
    Role = "primary"
    AZ   = data.aws_availability_zones.available.names[0]
  }
}

###############################################################################
# Instance RDS Replica – eu-west-3b
# aws_db_instance avec replicate_source_db = identifiant de la primary
# La replica est en lecture seule ; WordPress écrit toujours sur la primary
###############################################################################

resource "aws_db_instance" "replica" {
  identifier     = "${var.namespace}-db-replica"
  instance_class = var.db_instance_class

  # Lien vers la primary – transforme cette instance en Read Replica MySQL
  replicate_source_db = aws_db_instance.primary.identifier

  # Réseau – AZ différente de la primary
  availability_zone      = data.aws_availability_zones.available.names[1] # eu-west-3b
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false

  # Stockage (hérité de la primary mais on peut surcharger le type)
  storage_type      = "gp3"
  storage_encrypted = true

  # La replica n'a pas de db_name / username / password (hérités de la source)
  # Elle n'a pas non plus de backup_retention_period obligatoire

  parameter_group_name = aws_db_parameter_group.wordpress.name

  skip_final_snapshot = true # pas de snapshot final pour la replica

  auto_minor_version_upgrade = true

  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  # La replica doit attendre que la primary soit disponible
  depends_on = [aws_db_instance.primary]

  tags = {
    Name = "${var.namespace}-db-replica"
    Role = "replica"
    AZ   = data.aws_availability_zones.available.names[1]
  }
}
