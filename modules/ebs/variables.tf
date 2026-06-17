variable "ebs_size" {
  type    = number
  default = 10
}

variable "availability_zone" {
  description = "AZ dans laquelle creer le volume EBS"
  type        = string
}

variable "instance_id" {
  description = "ID de l'instance EC2 sur laquelle attacher le volume"
  type        = string
}

variable "namespace" {
  type = string
}