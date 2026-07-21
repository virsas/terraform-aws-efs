resource "aws_efs_file_system" "vss" {
  availability_zone_name = var.regional ? null : var.zone
  creation_token = var.name

  encrypted  = var.kms_id != null
  kms_key_id = var.kms_id

  performance_mode = var.performance_mode
  throughput_mode = var.throughput_mode != null ? var.throughput_mode : "bursting"

  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null

  tags = {
    Name = var.name
  }

  protection {
    replication_overwrite = var.replication_overwrite
  }
}

resource "aws_efs_mount_target" "vss" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.vss.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = var.security_groups
}