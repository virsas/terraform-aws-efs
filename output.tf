output "url" {
  value = aws_efs_file_system.vss.arn
}
output "id" {
  value = aws_efs_file_system.vss.id
}
output "dns_name" {
  value = aws_efs_file_system.vss.dns_name
}
output "name" {
  value = aws_efs_file_system.vss.name
}
output "number_of_mount_targets" {
  value = aws_efs_file_system.vss.number_of_mount_targets
}
output "owner_id" {
  value = aws_efs_file_system.vss.owner_id
}
output "size_in_bytes" {
  value = aws_efs_file_system.vss.size_in_bytes
}