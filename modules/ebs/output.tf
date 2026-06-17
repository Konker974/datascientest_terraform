output "volume_id" {
  description = "ID du volume EBS"
  value       = aws_ebs_volume.dst_ebs.id
}

output "attachment_id" {
  description = "ID de l'attachement du volume"
  value       = aws_volume_attachment.dst_ebs_att.id
}
