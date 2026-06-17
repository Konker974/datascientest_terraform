###############################################################################
# Data sources – AZ disponibles dans la région
###############################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

###############################################################################
# VPC
###############################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.namespace}-vpc"
  }
}

###############################################################################
# Internet Gateway
###############################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.namespace}-igw"
  }
}

###############################################################################
# Subnets
# – 1 subnet public  (eu-west-3a) → EC2 WordPress
# – 2 subnets privés (eu-west-3a et eu-west-3b) → RDS Multi-AZ
###############################################################################

# Subnet public – eu-west-3a (EC2 + point d'entrée HTTP/HTTPS)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.namespace}-subnet-public-3a"
    Tier = "public"
  }
}

# Subnet privé A – eu-west-3a (RDS Primary)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.namespace}-subnet-private-3a"
    Tier = "private"
  }
}

# Subnet privé B – eu-west-3b (RDS Standby – obligatoire pour Multi-AZ)
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.namespace}-subnet-private-3b"
    Tier = "private"
  }
}

###############################################################################
# Table de routage – Subnet public → Internet Gateway
###############################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.namespace}-rt-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Les subnets privés n'ont pas de route vers Internet (RDS isolé)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.namespace}-rt-private"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

###############################################################################
# Security Group – EC2 WordPress
# Autorise : HTTP (80), HTTPS (443), SSH (22) depuis Internet
#            trafic sortant libre
###############################################################################

resource "aws_security_group" "ec2_wordpress" {
  name        = "${var.namespace}-sg-ec2"
  description = "Security group pour l instance EC2 WordPress"
  vpc_id      = aws_vpc.main.id

  # HTTP public
  ingress {
    description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS public (bonus TLS)
  ingress {
    description = "HTTPS depuis Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH – restreindre à votre IP en production !
  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  # Tout le trafic sortant est autorisé
  egress {
    description = "Trafic sortant libre"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-sg-ec2"
  }
}

###############################################################################
# Security Group – RDS MySQL
# Autorise : MySQL (3306) uniquement depuis le SG EC2
#            aucune règle egress explicite nécessaire pour RDS
###############################################################################

resource "aws_security_group" "rds_mysql" {
  name        = "${var.namespace}-sg-rds"
  description = "Security group pour RDS MySQL acces restreint EC2 WordPress"
  vpc_id      = aws_vpc.main.id

  # MySQL uniquement depuis l'EC2 WordPress (référence par SG, pas par CIDR)
  ingress {
    description     = "MySQL depuis EC2 WordPress"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_wordpress.id]
  }

  tags = {
    Name = "${var.namespace}-sg-rds"
  }
}
