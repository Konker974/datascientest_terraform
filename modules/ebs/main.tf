resource "aws_ebs_volume" "dst_ebs" {
  availability_zone = var.availability_zone
  size              = var.ebs_size

  tags = {
    Name = "${var.namespace}-ebs"
  }
}

resource "aws_volume_attachment" "dst_ebs_att" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.dst_ebs.id
  instance_id  = var.instance_id
  force_detach = true
}
