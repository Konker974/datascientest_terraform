#Créez une Data Source aws_ami pour sélectionner l'ami disponible dans votre région
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Configurer l'instance EC2 dans un sous-réseau public
resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.amazon_linux2.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.ec2_sg_id]
  key_name                    = var.key_name
  availability_zone           = data.aws_availability_zones.available.names[0]
  user_data_replace_on_change = true
    lifecycle {
    create_before_destroy = false
  }

  user_data = templatefile("${path.root}/install_wordpress.sh.tftpl", {
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    db_host     = var.db_host
  })

  tags = {
    "Name" = "${var.namespace}-EC2-PUBLIC-APP"
  }
}